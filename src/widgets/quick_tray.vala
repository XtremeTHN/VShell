public class Quick.Tray: Button {
    AstalTray.Tray tray;
    
    construct {
        button.is_locked = true;
        tray = AstalTray.get_default ();

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