import Clutter from 'gi://Clutter';
import GObject from 'gi://GObject';
import St from 'gi://St';

import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as SystemActions from 'resource:///org/gnome/shell/misc/systemActions.js';
import { gettext as _ } from 'resource:///org/gnome/shell/extensions/extension.js';

export default class RebootButton extends PanelMenu.Button {
    static {
        GObject.registerClass({}, this);
    }

    constructor() {
        // the 0.5 is for any menu, wich we dont even use here
        super(0.5, _('Restart'), true);

        this.add_style_class_name('restart-button');
        this.add_child(new St.Icon({
            icon_name: 'system-reboot-symbolic',
            style_class: 'system-status-icon',
        }));

        this._systemActions = SystemActions.getDefault();
        this._systemActions.bind_property('can-restart', this, 'visible',
            GObject.BindingFlags.SYNC_CREATE);

        // left click only, dont bring up the prompt with another button
        this.connect('button-release-event', (_, ev) => {
            if (ev.get_button() !== Clutter.BUTTON_PRIMARY)
                return;

            // same as the power menu: they give us like 30 sec to cancel
            this._systemActions.activateRestart();
        });
    }
}