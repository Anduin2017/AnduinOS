'use strict';

import Gio from 'gi://Gio';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

const LIGHT_SCHEME_NAME   = 'prefer-light';
const DARK_SCHEME_NAME    = 'prefer-dark';
const GLib = imports.gi.GLib;

function runCommand(command) {
    try {
        let [stdout, stderr, exit_status] = GLib.spawn_command_line_sync(command);
        if (exit_status !== 0) {
            global.log(`Error running command: ${stderr}`);
        } else {
            global.log(`Command output: ${stdout}`);
        }
    } catch (e) {
        global.log(`Error running command: ${e}`);
    }
}

const LIGHT_THEME_SETTINGS = {
    "org.gnome.desktop.interface": {
        "color-scheme": LIGHT_SCHEME_NAME,
        "cursor-theme": "Fluent-dark-cursors",
        "gtk-theme": "Fluent-round-Light",
        "icon-theme": "Fluent-light",
    },
    "org.gnome.shell.extensions.user-theme": {
        "name": "Fluent-round-Light",
    },
};

const DARK_THEME_SETTINGS = {
    "org.gnome.desktop.interface": {
        "color-scheme": DARK_SCHEME_NAME,
        "cursor-theme": "Fluent-dark-cursors",
        "gtk-theme": "Fluent-round-Dark",
        "icon-theme": "Fluent-dark",
    },
    "org.gnome.shell.extensions.user-theme": {
        "name": "Fluent-round-Dark",
    },
};

function applySettings(settingsMap) {
    for (let schemaId in settingsMap) {
        let schema = new Gio.Settings({ schema: schemaId });
        let keyValues = settingsMap[schemaId];
        for (let key in keyValues) {
            schema.set_string(key, keyValues[key]);
            log(`LightDarkSwitcher: Setting ${schemaId}::${key} to ${keyValues[key]}`);
        }
    }
}

function hasBattery() {
    try {
        let dir = Gio.File.new_for_path('/sys/class/power_supply');
        let enumerator = dir.enumerate_children('standard::name', Gio.FileQueryInfoFlags.NONE, null);
        let info;
        while ((info = enumerator.next_file(null)) !== null) {
            if (info.get_name().startsWith('BAT')) {
                return true;
            }
        }
    } catch (e) {
        logError(e);
    }
    return false;
}

export default class LightDarkSwitcherExtension extends Extension {
    enable() {
        if (!hasBattery()) {
            let systemIndicator = Main.panel.statusArea.quickSettings._system;
            if (systemIndicator) {
                systemIndicator.hide();
            }
        }

        this._interfaceSettings = new Gio.Settings({ schema: 'org.gnome.desktop.interface' });
        this._settingsSignalId = this._interfaceSettings.connect(
            'changed::color-scheme',
            () => this._syncTheme()
        );
    }

    disable() {
        if (this._settingsSignalId && this._interfaceSettings) {
            this._interfaceSettings.disconnect(this._settingsSignalId);
            this._settingsSignalId = null;
        }
        this._interfaceSettings = null;
    }

    _syncTheme() {
        let scheme = this._interfaceSettings.get_string('color-scheme');
        if (scheme === DARK_SCHEME_NAME) {
            GLib.spawn_async(null, ['sh', '-c', "rm -rf $HOME/.config/gtk-4.0/*"], null, GLib.SpawnFlags.SEARCH_PATH, null);
	    GLib.spawn_async(null, ['sh', '-c', "ln -sf /usr/share/themes/Fluent-round-Dark/gtk-4.0/* $HOME/.config/gtk-4.0/"], null, GLib.SpawnFlags.SEARCH_PATH, null);
            applySettings(DARK_THEME_SETTINGS);
        } else {
            GLib.spawn_async(null, ['sh', '-c', "rm -rf $HOME/.config/gtk-4.0/*"], null, GLib.SpawnFlags.SEARCH_PATH, null);
	    GLib.spawn_async(null, ['sh', '-c', "ln -sf /usr/share/themes/Fluent-round-Light/gtk-4.0/* $HOME/.config/gtk-4.0/"], null, GLib.SpawnFlags.SEARCH_PATH, null);
            applySettings(LIGHT_THEME_SETTINGS);
        }
    }
}
