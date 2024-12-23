/* extension.js
 * GNOME 45+ / 46+ style extension
 */
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import GObject from 'gi://GObject';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';
import * as QuickSettings from 'resource:///org/gnome/shell/ui/quickSettings.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

/* =============== 常量 & 工具函数 =============== */
const LIGHT_SCHEME_NAME = "prefer-light";
const DARK_SCHEME_NAME = "prefer-dark";

const LIGHT_SCHEME_ICON = "weather-clear-symbolic";
const DARK_SCHEME_ICON  = "weather-clear-night-symbolic";

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

function applySettings(settingsObj) {
    for (let schemaId in settingsObj) {
        let schema = new Gio.Settings({ schema: schemaId });
        let keyValues = settingsObj[schemaId];
        for (let key in keyValues) {
            schema.set_string(key, keyValues[key]);
            log(`Setting ${schemaId} ${key} to ${keyValues[key]}`);
        }
    }
}

// 小工具：检测是否有电池
function deviceHasBattery() {
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

/* =============== Toggle 实现 =============== */
const ThemeToggle = GObject.registerClass(
class ThemeToggle extends QuickSettings.QuickMenuToggle {
    _init() {
        super._init({
            title: "Theme",
            iconName: LIGHT_SCHEME_ICON, // 初始图标
        });

        // 在面板下拉时会展示一个带标题的头部
        this.menu.setHeader(LIGHT_SCHEME_ICON, "Theme Switcher", "Switch between Light/Dark theme");

        // 放一个区块，里面添加“Light Theme”和“Dark Theme”按钮
        let itemsSection = new PopupMenu.PopupMenuSection();
        this._lightItem = itemsSection.addAction("Light Theme", () => {
            applySettings(LIGHT_THEME_SETTINGS);
            this._setIcon(LIGHT_SCHEME_ICON);
        });
        this._darkItem = itemsSection.addAction("Dark Theme", () => {
            applySettings(DARK_THEME_SETTINGS);
            this._setIcon(DARK_SCHEME_ICON);
        });

        // 将该区块添加到子菜单
        this.menu.addMenuItem(itemsSection);

        // 若需要分割线、或再加“打开设置”也可以：
        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
        this.menu.addSettingsAction(
            "GNOME Appearance Settings", 'gnome-appearance-panel.desktop'
        );

        // 点击主按钮（外面的开关）时，做一个简单地在 Light / Dark 之间切换的逻辑
        this.connect('clicked', this._onClicked.bind(this));
    }

    // 更新图标
    _setIcon(iconName) {
        this.iconName = iconName;
        this.subtitle = (iconName === LIGHT_SCHEME_ICON) ? "Light" : "Dark";
    }

    // 点击时切换
    _onClicked() {
        if (this.checked) {
            // 如果从未切换过，可视为“关 -> 开”，那就用 Dark
            applySettings(DARK_THEME_SETTINGS);
            this._setIcon(DARK_SCHEME_ICON);
        } else {
            // 反之用 Light
            applySettings(LIGHT_THEME_SETTINGS);
            this._setIcon(LIGHT_SCHEME_ICON);
        }
    }

    // 从系统当前设置检测颜色模式，更新图标/checked
    reflectSystemScheme() {
        let ifaceSettings = new Gio.Settings({ schema: "org.gnome.desktop.interface" });
        let currentScheme = ifaceSettings.get_string("color-scheme");

        // 当 color-scheme 是 "prefer-dark" 就是暗色，否则当作亮色
        if (currentScheme === DARK_SCHEME_NAME) {
            this._setIcon(DARK_SCHEME_ICON);
            this.checked = true;
        } else {
            this._setIcon(LIGHT_SCHEME_ICON);
            this.checked = false;
        }
    }
});

export default class ThemeSwitcherExtension extends Extension {
    constructor(metadata) {
        super(metadata);
    }

    enable() {
        // 1. 如果没有电池，则隐藏电源图标（注意此处字段名在不同 GNOME 版本可能不同）
        if (!deviceHasBattery()) {
            let powerIndicator = Main.panel.statusArea.quickSettings._power;
            if (powerIndicator) {
                powerIndicator.visible = false;
            }
        }

        // 2. 创建一个自定义 Toggle，并加到 QuickSettings 面板
        this._toggle = new ThemeToggle();
        this._indicator = new QuickSettings.SystemIndicator();
        this._indicator.quickSettingsItems.push(this._toggle);

        // 把我们自定义的 Indicator（里含 toggle）放进面板
        Main.panel.statusArea.quickSettings.addExternalIndicator(this._indicator);

        // 3. 监听系统 color-scheme 改变，以便动态更新图标
        this._settings = new Gio.Settings({ schema: "org.gnome.desktop.interface" });
        this._settingsSignalId = this._settings.connect("changed::color-scheme",
            () => this._toggle.reflectSystemScheme()
        );

        // 初始化时也同步一次
        this._toggle.reflectSystemScheme();
    }

    disable() {
        // 断开 signal
        if (this._settingsSignalId) {
            this._settings.disconnect(this._settingsSignalId);
            this._settingsSignalId = null;
        }
        this._settings = null;

        // 把之前隐藏的电源图标恢复可见（如果需要）
        let powerIndicator = Main.panel.statusArea.quickSettings._power;
        if (powerIndicator)
            powerIndicator.visible = true;

        // 销毁 UI
        if (this._toggle) {
            this._toggle.destroy();
            this._toggle = null;
        }
        if (this._indicator) {
            this._indicator.destroy();
            this._indicator = null;
        }
    }
}
