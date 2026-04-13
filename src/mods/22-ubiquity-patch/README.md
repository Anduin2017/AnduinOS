# Ubiquity Installer Patch & Crash Mitigation

This module contains the necessary patches to make the Ubiquity installer work reliably on modern Ubuntu environments (verified on Ubuntu 26.04 `resolute`).

## The Fragility of Ubiquity

Ubiquity is a legacy installer (Python 3 / GTK 3) that faces significant challenges on modern, highly sandboxed graphical stacks. On newer base images, it often crashes silently.

### Root Causes Identified

Through extensive live-environment debugging, we identified three independent failure points:

1.  **Environment Stripping (PYTHONPATH)**: When launched via `sudo`, the `PYTHONPATH` is stripped. Since Ubiquity modules reside in `/usr/lib/ubiquity`, the app fails at `import ubiquity`.
2.  **Kernel Restrictions (User Namespaces)**: Ubuntu 24.04+ restricts unprivileged user namespaces. Sandboxing tools like `bwrap` (used by GTK for SVG rendering) fail without specific permissions.
3.  **The Rendering Deadlock**: Modern GTK (via `libglycin`) renders SVG icons inside a `bwrap` sandbox. In the `resolute` image, these sandboxes often output warnings to `stderr`. If the parent process doesn't read this pipe, it deadlocks, causing a `status 1` exit code and a subsequent UI crash.
4.  **GPU Acceleration Instability**: On many Live environments, software rendering is mandatory for stability.
5.  **HOME Variable Conflict**: Preserving `HOME=/home/live` while running as `root` causes `bwrap` to fail its sandbox validation (due to UID/path mismatches).

## The Multi-Layered Solution

We use a combination of five strategies to ensure stability:

1.  **Environment Injection (with HOME exclusion)**: Explicitly adding `PYTHONPATH`, `XAUTHORITY`, `DISPLAY`, and `LIBGL_ALWAYS_SOFTWARE=1` to the `.desktop` launcher, while **explicitly NOT preserving HOME**. This ensures:
    *   Python can find the `ubiquity` module.
    *   The UI has permission to draw on the Wayland/X server.
    *   The root user uses its own home (`/root`), satisfying `bwrap` sandbox requirements.
2.  **Kernel Permission**: Enabling `kernel.apparmor_restrict_unprivileged_userns = 0` via the `43-gnome-sessions-patch` module.
3.  **Icon Cache Pre-generation**: Running `gtk-update-icon-cache` during the icon theme installation (`25-fluent-icon-theme`) avoids most SVG rendering.
4.  **Ephemeral Bwrap Wrapper**: To handle any remaining un-cached icons without leaving traces on the installed system, we inject an inline Bash string inside the `.desktop` file's `Exec` command. This dynamically replaces `/usr/bin/bwrap` in the Live RAM overlay, runs Ubiquity, and then restores it. Because Ubiquity copies the OS from the underlying pristine SquashFS (not the RAM overlay), the installed system gets the original, un-hacked `bwrap`, ensuring AppArmor security remains intact.

## Evolution of the Fix

We previously experimented with placing a physical shell wrapper script at `/usr/local/bin/start-anduinos-installer`, and later with an unreadable Base64 inline string. Both proved flawed: the physical script left useless artifacts on the installed system, while the Base64 string was difficult to audit and maintain. 

The current solution—an inline Bash command that patches the RAM overlay on-the-fly—achieves a 100% clean, "zero-trace" installation while maintaining code readability.

## Troubleshooting

If the installer still fails to launch, use the following command in the Live environment to see the Python stack trace or GTK errors:

```bash
journalctl -t ubiquity -n 100
```

Common indicators of failure include `ModuleNotFoundError` (missing PYTHONPATH) or `gdk-pixbuf-error-quark` (bwrap/sandbox issues).
