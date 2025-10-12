// ====================
// File: deskmon.c
// Daemon: watch ~/Desktop for new .desktop files, chmod +x and mark as trusted
// Compile: gcc `pkg-config --cflags --libs gio-2.0 glib-2.0` -O2 -o deskmon deskmon.c
// Install to /usr/local/bin/deskmon and run via systemd user service

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <limits.h>
#include <sys/stat.h>
#include <sys/inotify.h>
#include <dirent.h>
#include <glib.h>
#include <gio/gio.h>

#define EVENT_SIZE (sizeof(struct inotify_event))
#define BUF_LEN   (1024 * (EVENT_SIZE + 16))

static volatile sig_atomic_t running = 1;

static void handle_signal(int sig) {
    running = 0;
}

static void trust_file(const char *path) {
    struct stat st;
    if (stat(path, &st) < 0) {
        g_warning("stat(%s) failed: %s", path, strerror(errno));
        return;
    }

    if (chmod(path, st.st_mode | S_IXUSR | S_IXGRP | S_IXOTH) < 0) {
        g_warning("chmod(%s) failed: %s", path, strerror(errno));
    }

    GError *error = NULL;
    GFile *file = g_file_new_for_path(path);
    if (!g_file_set_attribute_string(
            file,
            "metadata::trusted",
            "true",
            G_FILE_QUERY_INFO_NONE,
            NULL,
            &error)) {
        g_warning("Failed to set trusted on %s: %s", path, error->message);
        g_clear_error(&error);
    }
    g_object_unref(file);

    g_message("Trusted and marked executable: %s", path);
}

static void initial_scan(const char *dir) {
    DIR *d = opendir(dir);
    if (!d) return;
    struct dirent *ent;
    while ((ent = readdir(d))) {
        if (ent->d_type == DT_REG) {
            size_t len = strlen(ent->d_name);
            if (len > 8) {
                char *suffix = g_utf8_casefold(ent->d_name + len - 8, -1);
                if (strcmp(suffix, ".desktop") == 0) {
                    char *path = g_build_filename(dir, ent->d_name, NULL);
                    g_message("Initial scan found .desktop file: %s", path);
                    trust_file(path);
                    g_free(path);
                }
                g_free(suffix);
            }
        }
    }
    closedir(d);
}

int main(void) {
    const char *home = getenv("HOME");
    if (!home) {
        g_error("HOME environment variable not set");
        return EXIT_FAILURE;
    }
    const char *desktop_dir = g_get_user_special_dir(G_USER_DIRECTORY_DESKTOP);
    if (!desktop_dir) {
        g_error("Could not determine user Desktop directory.");
        return EXIT_FAILURE;
    }
    char *watch_dir = g_strdup(desktop_dir);

    struct sigaction sa = { .sa_handler = handle_signal };
    sigaction(SIGINT, &sa, NULL);
    sigaction(SIGTERM, &sa, NULL);

    initial_scan(watch_dir);

    int fd = inotify_init();
    if (fd < 0) {
        g_error("inotify_init1 failed: %s", strerror(errno));
        g_free(watch_dir);
        return EXIT_FAILURE;
    }

    int wd = inotify_add_watch(fd, watch_dir, IN_CREATE | IN_MOVED_TO);
    if (wd < 0) {
        g_error("inotify_add_watch(%s) failed: %s", watch_dir, strerror(errno));
        close(fd);
        g_free(watch_dir);
        return EXIT_FAILURE;
    }

    char buf[BUF_LEN];
    while (running) {
        int length = read(fd, buf, BUF_LEN);
        if (length < 0 && errno == EINTR) {
            continue;
        }

        if (length <= 0) {
            break;
        }

        int offset = 0;
        while (offset < length) {
            struct inotify_event *ev = (struct inotify_event *)(buf + offset);
            if (!(ev->mask & IN_ISDIR) && (ev->mask & (IN_CREATE | IN_MOVED_TO))) {
                size_t name_len = strlen(ev->name);
                if (name_len > 8) {
                    char *suffix = g_utf8_casefold(ev->name + name_len - 8, -1);
                    if (strcmp(suffix, ".desktop") == 0) {
                        char *path = g_build_filename(watch_dir, ev->name, NULL);
                        g_message("Detected new .desktop file: %s", path);
                        trust_file(path);
                        g_free(path);
                    }
                    g_free(suffix);
                }
            }
            offset += EVENT_SIZE + ev->len;
        }
    }

    inotify_rm_watch(fd, wd);
    close(fd);
    g_free(watch_dir);
    return EXIT_SUCCESS;
}