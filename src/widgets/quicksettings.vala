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
    Gtk.Overlay ovrl = new Gtk.Overlay ();
    Gtk.Revealer rev = new Gtk.Revealer ();
    
    Gtk.Widget _content;

    new Quick.Settings? parent;

    public Gtk.Widget? content {
        get {
            return _content;
        }

        set {
            value.set_margin_top (10);
            value.set_margin_bottom (10);
            value.set_margin_start (10);
            value.set_margin_end (10);

            value.set_halign (Gtk.Align.CENTER);
            value.set_valign (Gtk.Align.CENTER);

            ovrl.add_overlay (value);
            ovrl.set_measure_overlay (value, true);

            _content = value;
        }
    }

    construct {
        var bg = new Background ();
        ovrl.set_child (bg);

        rev.set_transition_type (Gtk.RevealerTransitionType.CROSSFADE);
        rev.set_transition_duration (300);

        rev.set_child (ovrl);
        base.set_child (rev);

        var gesture = new Gtk.GestureClick ();
        bg.add_controller (gesture);

        gesture.released.connect (on_click_released);
    }

    void on_click_released (Gtk.GestureClick gesture, int n_press, double x, double y) {
        if (content == null) {
            warning ("no child");
            return;
        }

        close ();
    }

    public void present (Quick.Settings win) {
        win.add_overlay (this);
        rev.set_reveal_child (true);

        parent = win;
    }

    public void close () {
        rev.set_reveal_child (false);
        Timeout.add (590, () => {
            parent.pop_overlay ();
            return false;
        }, Priority.HIGH);
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