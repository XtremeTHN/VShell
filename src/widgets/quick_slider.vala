[GtkTemplate (ui = "/com/github/XtremeTHN/VShell/quick-slider.ui")]
public class Quick.Slider: Gtk.Box {
    [GtkChild]
    public unowned Gtk.Scale scale;

    [GtkChild]
    public unowned Gtk.Image icon;
    
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
    public string icon_name { get; set; }

    construct {
        scale.value_changed.connect (on_value_changed);
    }

    void on_value_changed () {
        if (scale.get_value () >= low_value)
            icon.add_css_class ("high");
        else
            icon.remove_css_class ("high");
    }
}