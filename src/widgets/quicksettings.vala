class Background: Gtk.Box {
    public Background () {
        Object ();
        add_css_class ("quick-overlay-background");

        set_hexpand (true);
        set_vexpand (true);

        set_valign (Gtk.Align.FILL);
        set_halign (Gtk.Align.FILL);
    }
}

public class Dialog: Adw.Bin {
    Gtk.Overlay ovrl;
    Gtk.Revealer rev;

    public Dialog () {
        Object ();

        rev = new Gtk.Revealer ();
        ovrl = new Gtk.Overlay ();
        var bg = new Background ();
        ovrl.set_child (bg);

        rev.set_transition_type (Gtk.RevealerTransitionType.CROSSFADE);
        rev.set_transition_duration (300);

        rev.set_child (ovrl);
        base.set_child (rev);
    }

    public new void set_child (Gtk.Widget widget) {
        widget.set_margin_top (10);
        widget.set_margin_bottom (10);
        widget.set_margin_start (10);
        widget.set_margin_end (10);

        widget.add_css_class ("adwaita-window");
        widget.add_css_class ("background");

        widget.set_halign (Gtk.Align.CENTER);
        widget.set_valign (Gtk.Align.CENTER);

        ovrl.add_overlay (widget);
        ovrl.set_measure_overlay (widget, true);
    }

    public void present (Quick.Settings win) {
        win.add_overlay (this);
        rev.set_reveal_child (true);
    }

    public void close (SourceFunc cb) {
        rev.set_reveal_child (false);
        Timeout.add (590, cb, Priority.HIGH);
    }
}

namespace Quick {
    [GtkTemplate (ui = "/com/github/XtremeTHN/VShell/quicksettings.ui")]
    public class Settings: Astal.Window {
        [GtkChild]
        public unowned Gtk.Overlay ovrl;

        Dialog current_diag;

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

            var key = new Gtk.EventControllerKey ();
            ovrl.add_controller (key);

            key.key_released.connect (on_key_released);
        }

        public void on_key_released (Gtk.EventControllerKey _, uint keyval, uint keycode, Gdk.ModifierType state) {
            if (keyval == Gdk.Key.Escape)
                pop_overlay ();
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
            current_diag.close (() => {
                ovrl.remove_overlay (current_diag);
                current_diag = null;
                return false;
            });
        }
    }

    public void register_types () {
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
        new Settings ();
    }
}