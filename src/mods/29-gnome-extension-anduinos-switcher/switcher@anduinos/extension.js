'use strict';

import GObject from 'gi://GObject';
import Gio from 'gi://Gio';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as QuickSettings from 'resource:///org/gnome/shell/ui/quickSettings.js';
import {Extension, gettext as _} from 'resource:///org/gnome/shell/extensions/extension.js';

/** 常量定义 **/
const DEFAULT_SCHEME_NAME = 'default';
const LIGHT_SCHEME_NAME   = 'prefer-light';
const DARK_SCHEME_NAME    = 'prefer-dark';

const LIGHT_SCHEME_ICON   = 'weather-clear-symbolic';
const DARK_SCHEME_ICON    = 'weather-clear-night-symbolic';

/**
 * 我们希望不仅仅修改 color-scheme，还要同步修改 gtk-theme, icon-theme 等。
 * 这里是两组示例设置。可根据你自己的主题名称进行调整。
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

/**
 * 批量设置若干 GSettings key
 */
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

/**
 * 判断是否有电池，以便隐藏电源图标
 */
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
 * 自定义的单一 “明暗模式” 开关，继承自 QuickSettings.QuickMenuToggle
 */
const LightDarkToggle = GObject.registerClass(
class LightDarkToggle extends QuickSettings.QuickMenuToggle {
    _init() {
        // 调用父类构造
        super._init({
            title: _("Theme"),
            iconName: LIGHT_SCHEME_ICON,  // 默认先设为亮
        });

        // 如果机器没有电池，则隐藏电源图标
        // （GNOME 45+ 里常见为 Main.panel.statusArea.quickSettings._system._powerToggle）
        if (!hasBattery()) {
            let systemIndicator = Main.panel.statusArea.quickSettings._system;
            if (systemIndicator?._powerToggle) {
                systemIndicator._powerToggle.hide();
            }
        }

        // 准备一个 GSettings，用于监听“color-scheme”外部变动
        this._interfaceSettings = new Gio.Settings({ schema: 'org.gnome.desktop.interface' });

        // 同步初始状态
        this._syncFromSystem();

        // 如果用户外部切换了 color-scheme，这里就会触发
        this._settingsSignalId = this._interfaceSettings.connect(
            'changed::color-scheme',
            () => this._syncFromSystem()
        );

        // 点击开关时，手动在扩展内切换
        this.connect('clicked', () => {
            this._onToggle();
        });
    }

    /**
     * 当从外部或通过系统设置改了 color-scheme 时调用
     * 我们在这里**重新应用**整套主题设置（LIGHT_THEME_SETTINGS / DARK_THEME_SETTINGS）
     */
    _syncFromSystem() {
        let scheme = this._interfaceSettings.get_string('color-scheme');

        if (scheme === DARK_SCHEME_NAME) {
            // 外部已切到 dark，我们也再度应用我们的 dark 设定
            applySettings(DARK_THEME_SETTINGS);
            this.iconName = DARK_SCHEME_ICON;
            this.checked = true;
        } else {
            // 其余情况(包含 'default', 'prefer-light') 归为 light
            applySettings(LIGHT_THEME_SETTINGS);
            this.iconName = LIGHT_SCHEME_ICON;
            this.checked = false;
        }
    }

    /**
     * 当用户手动点击这个开关时
     */
    _onToggle() {
        if (!this.checked) {
            // 当前是亮 -> 切到暗
            applySettings(DARK_THEME_SETTINGS);
            this.iconName = DARK_SCHEME_ICON;
            this.checked = true;
        } else {
            // 当前是暗 -> 切到亮
            applySettings(LIGHT_THEME_SETTINGS);
            this.iconName = LIGHT_SCHEME_ICON;
            this.checked = false;
        }
    }

    /**
     * 清理：断开 GSettings 信号
     */
    destroy() {
        if (this._settingsSignalId) {
            this._interfaceSettings.disconnect(this._settingsSignalId);
            this._settingsSignalId = null;
        }
        super.destroy();
    }
});


/**
 * 整个扩展入口类
 */
export default class LightDarkSwitcherExtension extends Extension {
    enable() {
        // 在 GNOME 45+ 中，我们先创建一个 SystemIndicator
        this._indicator = new QuickSettings.SystemIndicator();
        // 再创建一个自定义的 Toggle
        this._toggle = new LightDarkToggle();

        // 将 toggle 放进 indicator 的按钮列表
        this._indicator.quickSettingsItems.push(this._toggle);

        // 最后把这个 indicator 挂到系统的 quickSettings 面板里
        Main.panel.statusArea.quickSettings.addExternalIndicator(this._indicator);
    }

    disable() {
        // 清理
        if (this._indicator) {
            this._indicator.quickSettingsItems.forEach(item => item.destroy());
            this._indicator.destroy();
            this._indicator = null;
        }
    }
}
