[SingleInstance]
public class Network : Object {
    public AstalNetwork.Network net;

    public string tooltip_text { get; set; }
    public string icon_name { get; set; }

    public Network () {
        Object ();

        net = AstalNetwork.get_default ();

        net.notify["wifi"].connect (on_device_change);
        net.notify["wired"].connect (on_device_change);

        on_device_change ();
    }

    bool on_state_change (Binding _, Value from, ref Value to) {
        var state = (AstalNetwork.DeviceState) from.get_enum ();
        switch (state) {
            case AstalNetwork.DeviceState.ACTIVATED:
                //  to = "Connected (wired)";
                to.set_string ("Connected (wired)");
                break;
            case AstalNetwork.DeviceState.DEACTIVATING:
                //  to = "Disconnecting...";
                to.set_string ("Disconnecting...");
                break;
            case AstalNetwork.DeviceState.DISCONNECTED:
                to.set_string ("Disconnected");
                break;
            default:
                to.set_string("Unknown");
                message ("Unknown state: %s", state.to_string ());
                break;
        }
        return true;
    }

    void bind_icon (Object obj) {
        obj.bind_property ("icon-name", this, "icon-name", BindingFlags.SYNC_CREATE, null, null);
    }

    void on_device_change () {
        if (net.wifi != null) {
            message ("Wifi device detected");
            net.wifi.bind_property ("ssid", this, "tooltip-text", BindingFlags.SYNC_CREATE, null, null);
            bind_icon (net.wifi);
        }

        if (net.wired != null) {
            message ("Wired device detected");
            net.wired.bind_property ("state", this, "tooltip-text", BindingFlags.SYNC_CREATE, on_state_change, null);
            bind_icon (net.wired);
        }
    }
}

public void bind_net (Gtk.Image widget) {
    var net = new Network ();

    net.bind_property (
        "tooltip-text",
        widget,
        "tooltip-text",
        BindingFlags.SYNC_CREATE
    );

    net.bind_property (
        "icon-name",
        widget,
        "icon-name",
        BindingFlags.SYNC_CREATE
    );
}