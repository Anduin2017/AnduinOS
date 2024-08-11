const Main = imports.ui.main;
const Gio = imports.gi.Gio;
const PopupMenu = imports.ui.popupMenu;
const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const Gettext = imports.gettext.domain(Me.metadata.uuid);
const _ = Gettext.gettext;

const DEFAULT_SCHEME_NAME = "default";
const LIGHT_SCHEME_NAME = "prefer-light";
const DARK_SCHEME_NAME = "prefer-dark";
const LIGHT_SCHEME_ICON = "weather-clear-symbolic";
const DARK_SCHEME_ICON = "weather-clear-night-symbolic";

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

let switcherMenu;
let settings;

function applySettings(settings) {
    for (let schemaId in settings) {
        let schema = new Gio.Settings({ schema: schemaId });
        let keyValues = settings[schemaId];
        for (let key in keyValues) {
            schema.set_string(key, keyValues[key]);
            log(`Setting ${schemaId} ${key} to ${keyValues[key]}`);
        }
    }
}

class ThemeMenuToggle {
    constructor() {
        this._init();
    }

    _init() {
        this.menu = new PopupMenu.PopupSubMenuMenuItem(_("Theme"), true);
        this.menu.icon.icon_name = LIGHT_SCHEME_ICON;
        this._createMenuItems();
        this._reflectSettings();
    }

    _createMenuItems() {
        let itemsSection = new PopupMenu.PopupMenuSection();
        this._lightItem = new PopupMenu.PopupMenuItem(_("Light Theme"));
        this._lightItem.connect("activate", () => {
            applySettings(LIGHT_THEME_SETTINGS);
            this.menu.icon.icon_name = LIGHT_SCHEME_ICON;
        });
        itemsSection.addMenuItem(this._lightItem);

        this._darkItem = new PopupMenu.PopupMenuItem(_("Dark Theme"));
        this._darkItem.connect("activate", () => {
            applySettings(DARK_THEME_SETTINGS);
            this.menu.icon.icon_name = DARK_SCHEME_ICON;
        });
        itemsSection.addMenuItem(this._darkItem);

        this.menu.menu.addMenuItem(itemsSection);
    }

    _reflectSettings() {
        const scheme = settings.get_string("color-scheme");
        if (scheme === LIGHT_SCHEME_NAME || scheme === DEFAULT_SCHEME_NAME) {
            this.menu.icon.icon_name = LIGHT_SCHEME_ICON;
        } else if (scheme === DARK_SCHEME_NAME) {
            this.menu.icon.icon_name = DARK_SCHEME_ICON;
        }
    }

    destroy() {
        this.menu.destroy();
    }
}

function init() {
    ExtensionUtils.initTranslations(Me.metadata.uuid);
}

function enable() {
    settings = new Gio.Settings({ schema: "org.gnome.desktop.interface" });
    switcherMenu = new ThemeMenuToggle();
    Main.panel.statusArea.aggregateMenu.menu.addMenuItem(switcherMenu.menu, 3);
}

function disable() {
    if (switcherMenu) {
        switcherMenu.destroy();
        switcherMenu = null;
    }
}
