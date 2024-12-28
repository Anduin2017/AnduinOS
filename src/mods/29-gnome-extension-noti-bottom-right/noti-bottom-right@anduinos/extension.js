import Clutter from 'gi://Clutter';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

export default class NotificationPosition {

    constructor() {
        this._originalBannerAlignment = Main.messageTray.bannerAlignment;
        this._originalYAlign = Main.messageTray.actor.get_y_align();
    }

    rightBottom() {
        Main.messageTray.bannerAlignment = Clutter.ActorAlign.END;
        Main.messageTray.actor.set_y_align(Clutter.ActorAlign.END);
    }

    _original() {
        Main.messageTray.bannerAlignment = this._originalBannerAlignment;
        Main.messageTray.actor.set_y_align(this._originalYAlign);
    }

    enable() {
        this.rightBottom();
    }

    disable() {
        this._original();
    }
}
