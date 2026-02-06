namespace Quick {
    public class PowerMenu: Menu {
        Logind login;
        public delegate void ButtonClicked ();

        public PowerMenu () {
            Object ();

            login = Logind.get_instance ();

            heading = "Power Off";
            icon_name = "system-shutdown-symbolic";

            listbox.append (new_button ("Suspend", suspend));
            listbox.append (new_button ("Reboot...", reboot));
            listbox.append (new_button ("Power Off...", poweroff));

            pack_end (new_button ("Log Out...", logout));

            stack.remove(placeholder);
            stack.set_visible_child_name ("main");
        }

        void schedule (string title, ShutdownMode? mode, Utils.SimpleFunction cb) {
            var win = new AlertWindow ();
            win.heading = title;
            win.body = @"The system will $(title.down ()) automatically in 60 seconds";

            uint time_id = 0;
            
            var cancel = win.add_choice ("Cancel");
            var confirm = win.add_choice (title);

            cancel.clicked.connect (() => {
                try {
                    login.cancel_scheduled_shutdown ();

                    if (time_id > 0)
                        Source.remove (time_id);
                } catch (Error e) {
                    critical ("couldn't cancel scheduled shutdown: %s", e.message);
                }

                win.close ();
            });

            confirm.clicked.connect (() => {
                cb ();
            });
            
            if (mode != null)
                login.schedule_shutdown (mode, 60);
            else
                time_id = Timeout.add_seconds (60, () => {
                    cb ();
                    return Source.REMOVE;
                });

            win.present ();
        }

        void suspend () {
            Utils.try_func (login.suspend, "Couldn't suspend");
        }

        void logout () {
            schedule ("Log Out", null, () => {
                login.log_out ();
            });
        }

        void reboot () {
            schedule ("Reboot", ShutdownMode.REBOOT, login.reboot);
        }

        void poweroff () {
            schedule ("Power Off", ShutdownMode.POWEROFF, login.power_off);
        }

        Gtk.Button new_button (string label, ButtonClicked callback) {
            var widget = new Gtk.Button ();
            widget.set_hexpand (true);
            widget.add_css_class ("flat");

            var label_widget = new Gtk.Label (label);
            label_widget.set_xalign (0);
            widget.set_child (label_widget);

            widget.clicked.connect (() => {
                close ();
                parent_win.set_visible (false);

                callback ();
            });

            return widget;
        }
    }

    [GtkTemplate (ui = "/com/github/XtremeTHN/VShell/quicksettings.ui")]
    public class Settings: Astal.Window {
        [GtkChild]
        public unowned Gtk.Overlay ovrl;

        Dialog current_diag;

        PowerMenu power_menu;
        Logind login;

        public Settings () {
            Object (
                anchor: Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.RIGHT,
                name: "quicksettings",
                namespace: "vshell-quicksettings",
                keymode: Astal.Keymode.ON_DEMAND,
                resizable: false,
                width_request: 400,
                margin: 10
            );

            power_menu = new PowerMenu ();
            login = Logind.get_instance ();

            var key = new Gtk.EventControllerKey ();
            ovrl.add_controller (key);

            key.key_released.connect (on_key_released);
        }

        [GtkCallback]
        void on_power_clicked () {
            power_menu.present (this);
        }
        

        // TODO: exec a screen lock
        [GtkCallback]
        void on_lock_clicked () {
            //  Utils.try_func (login.lock, "Couldn't lock the session");
        }

        public void on_key_released (Gtk.EventControllerKey _, uint keyval, uint keycode, Gdk.ModifierType state) {
            if (keyval != Gdk.Key.Escape || current_diag == null)
                return;
            
            current_diag.close ();
        }

        public void add_overlay (Dialog diag) {
            if (current_diag != null) {
                warning ("another dialog is showing");
                return;
            }
            current_diag = diag;

            ovrl.add_overlay (diag);
            ovrl.set_measure_overlay (diag, true);
        }

        public void pop_overlay () {
            if (current_diag == null) {
                warning ("no current dialog");
                return;
            }
            
            ovrl.remove_overlay (current_diag);
            current_diag = null;
        }
    }

    public void register_types () {
        new Background ();
        new Dialog ();
        new ToggleButton ();
        new Button ();
        new Slider ();
        new AudioSlider ();
        new BacklightSlider ();
        new Internet ();
        new Quick.Bluetooth ();
        new PowerMode ();
        new Tray ();
        new Battery ();
        new Dialog ();
        new Menu ();
        new Settings ();
    }
}