public class Quick.Background: Gtk.Box {
    public Background () {
        Object ();
        add_css_class ("quick-overlay-background");

        set_hexpand (true);
        set_vexpand (true);

        set_valign (Gtk.Align.FILL);
        set_halign (Gtk.Align.FILL);
    }
}

public class Quick.Dialog: Adw.Bin {
    Gtk.Overlay ovrl = new Gtk.Overlay ();
    Gtk.Revealer rev = new Gtk.Revealer ();
    
    Gtk.Widget _content;

    public Quick.Settings? parent_win;

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

        parent_win = win;
    }

    public void close () {
        rev.set_reveal_child (false);
        Timeout.add (590, () => {
            parent_win.pop_overlay ();
            return false;
        }, Priority.HIGH);
    }
}