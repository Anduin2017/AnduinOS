'use strict';

import Gio from 'gi://Gio';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

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
    }

    disable() {

    }
}
