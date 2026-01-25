public class BluetoothIcon: Adw.Bin {
    Gtk.Image image;
    AstalBluetooth.Bluetooth blue;

    public bool hide_when_null = true;
    public bool _has_tooltip = true;

    construct {
        image = new Gtk.Image ();
        blue = AstalBluetooth.Bluetooth.get_default ();

        blue.bind_property (
            "is-powered",
            image,
            "icon-name",
            BindingFlags.SYNC_CREATE,
            (_, from, ref to) => {
                to.set_string (from.get_boolean () ? "bluetooth-symbolic" : "bluetooth-disabled-symbolic");
                return true;
            },
            null
        );

        blue.notify["adapter"].connect (on_adapter_change); 

        set_child (image);
    }

    void on_adapter_change () {
        var adapter = blue.adapter;
        
        if (adapter == null) {
            if (hide_when_null)
                image.set_visible (false);

            return;
        }

        image.set_visible (true);

        if (_has_tooltip)
            image.set_tooltip_text (adapter.powered ? "Enabled" : "Disabled");
    }
}

