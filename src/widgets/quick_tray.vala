public class Quick.Tray: Button {
    AstalTray.Tray tray;
    
    construct {
        button.is_locked = true;
        tray = AstalTray.get_default ();

        tray.items_model.items_changed.connect (on_tray_changed);
    }

    void on_tray_changed () {
        body = "%u apps running".printf(tray.items_model.get_n_items ());
    }
}