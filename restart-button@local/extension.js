import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import RebootButton from './indicator.js';

export default class RebootExtension extends Extension {
    enable() {
        // at the far end of the panel, after the battery percentage
        this._button = new RebootButton();
        Main.panel.addToStatusArea('restart-button', this._button, 100, 'right');
    }

    disable() {
        this._button?.destroy();
        this._button = null;
    }
}