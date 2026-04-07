import Clutter from 'gi://Clutter';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

export default class NotificationPosition {
    constructor() {
        this._bannerActor = Main.messageTray._bannerBin ?? Main.messageTray.actor ?? null;
        this._originalBannerAlignment = Main.messageTray.bannerAlignment;
        this._originalYAlign =
            (this._bannerActor && this._bannerActor.get_y_align)
                ? this._bannerActor.get_y_align()
                : Clutter.ActorAlign.START; // 默认为顶端
    }

    rightBottom() {
        Main.messageTray.bannerAlignment = Clutter.ActorAlign.END;
        if (this._bannerActor && this._bannerActor.set_y_align)
            this._bannerActor.set_y_align(Clutter.ActorAlign.END);
    }

    _original() {
        Main.messageTray.bannerAlignment = this._originalBannerAlignment;

        if (this._bannerActor && this._bannerActor.set_y_align)
            this._bannerActor.set_y_align(this._originalYAlign);
    }

    enable() { this.rightBottom(); }
    disable() { this._original(); }
}
