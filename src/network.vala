public class Network: Object {
    private static GLib.Once<Network> instance;

    public static Network get_instance () {
        return instance.once (() => {
            return new Network ();
        });
    }

    public string tooltip_text { get; set; default = "Unknown"; }
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

    AstalNetwork.Network net;

    Network () {
        Object ();

        net = AstalNetwork.Network.get_default ();

        Utils.on_notify (net, "state", on_state_change);
        Utils.on_notify (net, "primary", on_primary_change);
    }

    void bind_props (AstalNetwork.Primary type) {
        Object? obj = null;
        if (type == AstalNetwork.Primary.WIFI) {
            obj = net.wifi;
            obj.bind_property ("ssid", this, "tooltip-text", BindingFlags.SYNC_CREATE);
        } else
            obj = net.wired;

        obj.bind_property ("icon-name", this, "icon-name", BindingFlags.SYNC_CREATE, null, null);
    }

    void on_primary_change () {
        bind_props (net.primary);
    }

    void on_state_change () {
        switch (net.state) {
            case AstalNetwork.State.CONNECTED_GLOBAL:
            case AstalNetwork.State.CONNECTED_LOCAL:
            case AstalNetwork.State.CONNECTED_SITE:
                tooltip_text = "Connected";
                _active = true;
                break;

            case AstalNetwork.State.CONNECTING:
                tooltip_text = "Connecting...";
                _active = false;
                break;

            case AstalNetwork.State.DISCONNECTING:
                tooltip_text = "Disconnecting...";
                _active = true;
                break;

            case AstalNetwork.State.DISCONNECTED:
                tooltip_text = "Disconnected";
                _active = false;
                break;

            case AstalNetwork.State.ASLEEP:
                break;

            default:
                tooltip_text = "Unknown";
                _active = false;
                message ("Unknown state: %s", net.state.to_string ());
                break;
        }

        notify_property ("active");
    }
}