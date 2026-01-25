public class Quick.Bluetooth: Button {
    AstalBluetooth.Bluetooth blue;
    
    construct {
        blue = AstalBluetooth.get_default ();

        var icon = new BluetoothIcon ();
        icon.hide_when_null = false;
        icon._has_tooltip = false;

        set_icon_widget (icon);
        
        Utils.on_notify (blue, "adapter", on_adapter_changed);
        Utils.on_notify (blue, "devices", on_devices_changed);
    }

    void on_devices_changed () {
        foreach (var x in blue.devices) {
            if (x.connected == false) continue;

            body_widget.set_visible (true);
            body_widget.set_label (x.alias);
            return;
        }
        
        body_widget.set_visible (false);
    }

    void on_adapter_changed () {
        var adapter = blue.adapter;
        bool is_not_null = adapter != null;

        set_sensitive (is_not_null);
        body_widget.set_visible (is_not_null);

        if (!is_not_null)
            return;
    }
}