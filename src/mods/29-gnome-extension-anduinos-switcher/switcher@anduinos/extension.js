'use strict';

import GObject from 'gi://GObject';
import Gio from 'gi://Gio';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as QuickSettings from 'resource:///org/gnome/shell/ui/quickSettings.js';
import {Extension, gettext as _} from 'resource:///org/gnome/shell/extensions/extension.js';

/** 常量定义 **/
const DEFAULT_SCHEME_NAME = 'default';
const LIGHT_SCHEME_NAME = 'prefer-light';
const DARK_SCHEME_NAME = 'prefer-dark';
const LIGHT_SCHEME_ICON = 'weather-clear-symbolic';
const DARK_SCHEME_ICON = 'weather-clear-night-symbolic';

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

/** 应用主题设置的小工具函数 **/
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

/** 检查是否有电池 **/
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

/**
 * 自定义的 LightDarkToggle，继承 QuickSettings.QuickMenuToggle
 * 并监听外部系统主题变化。
 */
const LightDarkToggle = GObject.registerClass(
class LightDarkToggle extends QuickSettings.QuickMenuToggle {
    _init() {
        super._init({
            title: _("Theme"),
            iconName: LIGHT_SCHEME_ICON,  // 默认先设为亮
        });

        // 如果没有电池，就隐藏电源按钮（不同版本 GNOME 可能字段略不同）
        if (!hasBattery()) {
            let systemIndicator = Main.panel.statusArea.quickSettings._system;
            if (systemIndicator?._powerToggle) {
                systemIndicator._powerToggle.hide();
            }
        }

        // 创建对 interface 的 GSettings 引用，用于监听 color-scheme
        this._interfaceSettings = new Gio.Settings({ schema: 'org.gnome.desktop.interface' });
        // 同步初始状态
        this._syncFromSystem();

        // 监听 color-scheme 改变，如果从外部切换主题，这里会被触发
        this._settingsSignalId = this._interfaceSettings.connect(
            'changed::color-scheme',
            () => this._syncFromSystem()
        );

        // 当按钮被点击时，手动在扩展内执行切换
        this.connect('clicked', () => {
            this._onToggle();
        });
    }

    /**
     * _syncFromSystem()
     * 从系统设置中读取当前 color-scheme，更新图标和 checked 状态
     */
    _syncFromSystem() {
        let scheme = this._interfaceSettings.get_string('color-scheme');
        if (scheme === DARK_SCHEME_NAME) {
            this.iconName = DARK_SCHEME_ICON;
            this.checked = true;
        } else {
            // 包含 'default'、'prefer-light' 都视作亮
            this.iconName = LIGHT_SCHEME_ICON;
            this.checked = false;
        }
    }

    /**
     * _onToggle()
     * 当用户点击时（即 toggle 状态变动），执行明暗切换
     */
    _onToggle() {
        if (!this.checked) {
            // 由亮切到暗
            applySettings(DARK_THEME_SETTINGS);
            this.iconName = DARK_SCHEME_ICON;
            this.checked = true;
        } else {
            // 由暗切回亮
            applySettings(LIGHT_THEME_SETTINGS);
            this.iconName = LIGHT_SCHEME_ICON;
            this.checked = false;
        }
    }

    /**
     * 如果我们要在 disable() 时确保断开信号
     */
    destroy() {
        if (this._settingsSignalId) {
            this._interfaceSettings.disconnect(this._settingsSignalId);
            this._settingsSignalId = null;
        }
        super.destroy();
    }
});


export default class LightDarkSwitcherExtension extends Extension {
    enable() {
        // 建立一个 SystemIndicator（GNOME 45+）
        this._indicator = new QuickSettings.SystemIndicator();
        this._toggle = new LightDarkToggle();

        // 将 toggle 插入到 indicator 的列表里
        this._indicator.quickSettingsItems.push(this._toggle);

        // 把这个 indicator 注册到 quick settings 面板里
        Main.panel.statusArea.quickSettings.addExternalIndicator(this._indicator);
    }

    disable() {
        // 在 disable() 时销毁组件
        if (this._indicator) {
            this._indicator.quickSettingsItems.forEach(item => item.destroy());
            this._indicator.destroy();
            this._indicator = null;
        }
    }
}
