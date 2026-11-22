import Clutter from 'gi://Clutter';
import GLib from 'gi://GLib';
import St from 'gi://St';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';
import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';

export default class OmarchyPomodoroExtension extends Extension {
    enable() {
        try {
            this._indicator = new PanelMenu.Button(0.0, 'Omarchy Pomodoro', false);
            
            this._label = new St.Label({
                text: '🍅 25:00',
                y_align: Clutter.ActorAlign.CENTER
            });
            this._indicator.add_child(this._label);

            const home = GLib.get_home_dir();
            const pyPath = `${home}/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py`;

            // Menu Header
            let titleItem = new PopupMenu.PopupMenuItem('🍅 Omarchy Pomodoro', { reactive: false });
            this._indicator.menu.addMenuItem(titleItem);
            this._indicator.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

            // Quick Controls
            let toggleItem = new PopupMenu.PopupMenuItem('▶ / ⏸  Start / Pause');
            toggleItem.connect('activate', () => {
                GLib.spawn_command_line_async(`python3 "${pyPath}" toggle`);
                this._updateStatus();
            });
            this._indicator.menu.addMenuItem(toggleItem);

            let skipItem = new PopupMenu.PopupMenuItem('⏭  Skip Phase');
            skipItem.connect('activate', () => {
                GLib.spawn_command_line_async(`python3 "${pyPath}" skip`);
                this._updateStatus();
            });
            this._indicator.menu.addMenuItem(skipItem);

            let resetItem = new PopupMenu.PopupMenuItem('↺  Reset Timer');
            resetItem.connect('activate', () => {
                GLib.spawn_command_line_async(`python3 "${pyPath}" reset`);
                this._updateStatus();
            });
            this._indicator.menu.addMenuItem(resetItem);

            this._indicator.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

            // Presets Submenu
            let presetsMenu = new PopupMenu.PopupSubMenuMenuItem('⏱ Presets', false);
            
            let p25 = new PopupMenu.PopupMenuItem('Classic (25m / 5m)');
            p25.connect('activate', () => {
                GLib.spawn_command_line_async(`python3 -c "import sys; sys.path.insert(0, '${home}/.config/omarchy/plugins/khudoydev.pomodoro'); from pomodoro import save_state, load_state; s=load_state(); s['focus_sec']=1500; s['break_sec']=300; s['remaining_sec']=1500; s['is_running']=False; save_state(s)"`);
                this._updateStatus();
            });
            presetsMenu.menu.addMenuItem(p25);

            let p50 = new PopupMenu.PopupMenuItem('Deep Work (50m / 10m)');
            p50.connect('activate', () => {
                GLib.spawn_command_line_async(`python3 -c "import sys; sys.path.insert(0, '${home}/.config/omarchy/plugins/khudoydev.pomodoro'); from pomodoro import save_state, load_state; s=load_state(); s['focus_sec']=3000; s['break_sec']=600; s['remaining_sec']=3000; s['is_running']=False; save_state(s)"`);
                this._updateStatus();
            });
            presetsMenu.menu.addMenuItem(p50);

            let p15 = new PopupMenu.PopupMenuItem('Fast Sprint (15m / 3m)');
            p15.connect('activate', () => {
                GLib.spawn_command_line_async(`python3 -c "import sys; sys.path.insert(0, '${home}/.config/omarchy/plugins/khudoydev.pomodoro'); from pomodoro import save_state, load_state; s=load_state(); s['focus_sec']=900; s['break_sec']=180; s['remaining_sec']=900; s['is_running']=False; save_state(s)"`);
                this._updateStatus();
            });
            presetsMenu.menu.addMenuItem(p15);

            this._indicator.menu.addMenuItem(presetsMenu);

            // Add to panel immediately
            Main.panel.addToStatusArea(this.uuid, this._indicator);

            // Status updater
            this._updateStatus = () => {
                try {
                    let [res, out] = GLib.spawn_command_line_sync(`python3 "${pyPath}" waybar`);
                    if (res && out && out.length > 0) {
                        let jsonStr = new TextDecoder().decode(out).trim();
                        let data = JSON.parse(jsonStr);
                        if (data && data.text) {
                            this._label.set_text(data.text);
                        }
                    }
                } catch (e) {
                    console.error('[Omarchy Pomodoro] Update error:', e);
                }
            };

            this._updateStatus();
            this._timeout = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, () => {
                this._updateStatus();
                return GLib.SOURCE_CONTINUE;
            });
        } catch (err) {
            console.error('[Omarchy Pomodoro] enable() failed:', err);
        }
    }

    disable() {
        if (this._timeout) {
            GLib.Source.remove(this._timeout);
            this._timeout = null;
        }
        if (this._indicator) {
            this._indicator.destroy();
            this._indicator = null;
        }
    }
}
