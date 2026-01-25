public class Quick.ToggleButton: Gtk.Button {
    public bool is_locked { get; set; }

    public bool active {
        get {
            return has_css_class ("checked");
        }
        set {
            if (is_locked)
                return;

            if (value)
                add_css_class ("checked");
            else
                remove_css_class ("checked");
        }
    }

    construct {
        add_css_class ("toggle");
    }
}

[GtkTemplate (ui = "/com/github/XtremeTHN/VShell/quick-button.ui")]
public class Quick.Button: Adw.Bin {
    [GtkChild]
    public unowned ToggleButton button;

    [GtkChild]
    public unowned Gtk.Button end_button;

    [GtkChild]
    public unowned Gtk.Image icon;

    [GtkChild]
    public unowned Gtk.Box content;

    [GtkChild]
    public unowned Gtk.Label body_widget;

    public string icon_name { get; set; }
    public string heading { get; set; }
    public string body { get; set; }

    public signal void show_menu ();

    construct {
        button.notify["active"].connect (on_active);
    }

    public void set_icon_widget (Gtk.Widget icon) {
        content.remove(this.icon);
        content.prepend (icon);
    } 

    void on_active () {
        if (button.active)
            end_button.add_css_class ("checked");
        else
            end_button.remove_css_class ("checked");
    }

    [GtkCallback]
    void on_end_clicked () {
        show_menu ();
    }
}