import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import RebootButton from './indicator.js';

log('restart-button: module loaded');

export default class RebootExtension extends Extension {
    enable() {
        // next to the power off one, pos 1 so it lands on the right
        this._button = new RebootButton();
        Main.panel.addToStatusArea('restart-button', this._button, 1, 'right');
    }

    disable() {
        this._button?.destroy();
        this._button = null;
    }
}