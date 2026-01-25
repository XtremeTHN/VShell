[GtkTemplate (ui = "/com/github/XtremeTHN/VShell/quick-slider.ui")]
public class Quick.Slider: Gtk.Box {
    [GtkChild]
    public unowned Gtk.Scale scale;

    [GtkChild]
    public unowned Gtk.Overlay ovr;

    Gtk.Widget icon;
    
    double low_value;
    double _max;
    public double max {
        get {
            return _max;
        }
        set {
            _max = value;
            low_value = (6 * value) / 100;
        }
    }

    string _icon_name;
    public string icon_name {
        get {
            return _icon_name;
        }

        set {
            if (icon == null) 
                set_icon_widget (new Gtk.Image ());

            if (icon is Gtk.Image) {
                ((Gtk.Image) icon).set_from_icon_name (value);
                _icon_name = value;
            } else
                warning ("widget is not an image");
        }
    }

    construct {
        scale.value_changed.connect (on_value_changed);
    }

    public void set_icon_widget (Gtk.Widget icon) {
        icon.add_css_class ("quickslider-icon");
        icon.set_halign (Gtk.Align.START);
        icon.set_margin_start (10);

        if (this.icon != null)
            ovr.remove_overlay (this.icon);
        
        ovr.add_overlay (icon);
        this.icon = icon;
    }

    void on_value_changed () {
        if (scale.get_value () >= low_value)
            icon.add_css_class ("high");
        else
            icon.remove_css_class ("high");
    }
}