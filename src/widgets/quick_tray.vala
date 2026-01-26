public class Quick.TrayMenu: Menu {
    AstalTray.Tray tray;

    public TrayMenu () {
        Object ();

        heading = "System Tray";
        icon_name = "background-app-symbolic";
        placeholder_title = "No apps running";
        placeholder_icon_name = icon_name;
        has_end_buttons = false;

        tray = AstalTray.get_default ();

        set_model (tray.items_model, create_widget);

    }

    void on_button_clicked (Gtk.PopoverMenu menu, AstalTray.TrayItem item) {
        item.about_to_show ();
        menu.popup ();
    }

    Gtk.Widget create_widget (Object obj) {
        var item = (AstalTray.TrayItem) obj;

        var widget = new Gtk.Button ();
        var contents = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
        var icon = new Gtk.Image ();
        var label = new Gtk.Label (null);
        var popover = new Gtk.PopoverMenu.from_model (item.menu_model);

        icon.set_from_gicon (item.gicon);
        label.set_label (Utils.to_title (item.title));

        contents.append (icon);
        contents.append (label);

        widget.set_child (contents);

        widget.clicked.connect (() => {
            on_button_clicked (popover, item);
        });

        widget.add_css_class ("flat");
        widget.destroy.connect (() => {
            popover.unparent ();
            popover.destroy ();
        });

        popover.set_parent (widget);

        return widget;
    }
}

public class Quick.Tray: Button {
    AstalTray.Tray tray;
    
    construct {
        tray = AstalTray.get_default ();
        menu = new TrayMenu ();

        tray.items_model.items_changed.connect (on_tray_changed);
        on_tray_changed ();
    }

    void on_tray_changed () {
        var length = tray.items_model.get_n_items ();
        
        body_widget.set_visible (length > 0);

        string letter = "";
        if (length > 1)
            letter = "s";

        body = "%u app%s running".printf(length, letter);
    }
}