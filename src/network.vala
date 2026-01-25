[SingleInstance]
public class Network : Object {
    public AstalNetwork.Network net;

    public string tooltip_text { get; set; }
    public string icon_name { get; set; }
    
    bool _active = false;
    public bool active {
        get {
            return _active;
        }
        set {
            if (net.wifi != null) {
                net.wifi.enabled = value;
                _active = value;
            }
        }
    }

    construct {
        net = AstalNetwork.get_default ();

        net.notify["wifi"].connect (on_device_change);
        net.notify["wired"].connect (on_device_change);

        on_device_change ();
    }

    void on_state_change (AstalNetwork.DeviceState state) {
        switch (state) {
            case AstalNetwork.DeviceState.ACTIVATED:
                tooltip_text = "Connected (wired)";
                _active = true;
                break;
            case AstalNetwork.DeviceState.DEACTIVATING:
                tooltip_text = "Disconnecting...";
                _active = true;
                break;
            case AstalNetwork.DeviceState.DISCONNECTED:
                tooltip_text = "Disconnected";
                _active = false;
                break;
            default:
                tooltip_text = "Unknown";
                _active = false;
                message ("Unknown state: %s", state.to_string ());
                break;
        }

        notify_property ("active");
    }

    void bind_icon (Object obj) {
        obj.bind_property ("icon-name", this, "icon-name", BindingFlags.SYNC_CREATE, null, null);
    }

    void on_device_change () {
        var wifi = net.wifi;
        var wired = net.wired;
        if (wifi != null && wired == null) {
            message ("Wifi device detected");
            wifi.bind_property ("ssid", this, "tooltip-text", BindingFlags.SYNC_CREATE, null, null);
            Utils.on_notify (wifi, "state", () => {
                on_state_change (wifi.state);
            });
            bind_icon (wifi);
        }

        // wired will take precedence
        if (wired != null) {
            message ("Wired device detected");
            Utils.on_notify (wired, "state", () => {
                on_state_change (wired.state);
            });
            bind_icon (wired);
        }
    }
}