'use strict';

import Gio from 'gi://Gio';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

/** 常量定义 **/
const LIGHT_SCHEME_NAME   = 'prefer-light';
const DARK_SCHEME_NAME    = 'prefer-dark';

/**
 * 两套示例设置，可根据你自己的主题名称进行调整
 */
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

/** 批量应用 GSettings key/value **/
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

/** 检查机器是否有电池 **/
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
        // 如果设备无电池，则隐藏电源图标
        // (GNOME 45+ 中通常在 quickSettings._system._powerToggle)
        if (!hasBattery()) {
            let systemIndicator = Main.panel.statusArea.quickSettings._system;
            if (systemIndicator?._powerToggle) {
                systemIndicator._powerToggle.hide();
            }
        }

        // 监听 org.gnome.desktop.interface 的 color-scheme 改动
        this._interfaceSettings = new Gio.Settings({ schema: 'org.gnome.desktop.interface' });
        this._settingsSignalId = this._interfaceSettings.connect(
            'changed::color-scheme',
            () => this._syncTheme()
        );

        // 启动时先同步一次
        this._syncTheme();
    }

    disable() {
        // 断开信号
        if (this._settingsSignalId && this._interfaceSettings) {
            this._interfaceSettings.disconnect(this._settingsSignalId);
            this._settingsSignalId = null;
        }
        this._interfaceSettings = null;
    }

    /**
     * 根据当前系统 color-scheme，应用 LIGHT_THEME_SETTINGS 或 DARK_THEME_SETTINGS
     */
    _syncTheme() {
        let scheme = this._interfaceSettings.get_string('color-scheme');
        if (scheme === DARK_SCHEME_NAME) {
            applySettings(DARK_THEME_SETTINGS);
        } else {
            applySettings(LIGHT_THEME_SETTINGS);
        }
    }
}
