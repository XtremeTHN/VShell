[GtkTemplate (ui = "/com/github/XtremeTHN/VShell/quick-slider.ui")]
public class Quick.Slider: Gtk.Box {
    [GtkChild]
    public unowned Gtk.Scale scale;

    [GtkChild]
    public unowned Gtk.Image icon;
    
    public double max { get; set; }
    public string icon_name { get; set; }
    public double low_value { get; set; default = 25; }

    construct {
        scale.value_changed.connect (on_value_changed);
    }

    void on_value_changed () {
        if (scale.get_value () <= low_value)
            icon.add_css_class ("low");
        else
            icon.remove_css_class ("low");
    }
}