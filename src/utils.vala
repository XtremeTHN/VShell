namespace Utils {
    public delegate void NotiftySignalHandler ();

    public class SafeSignal {
        Object? obj;
        ulong? id;
        public SafeSignal (Object obj, ulong id) {
            this.obj = obj;
            this.id = id;
        }

        ~SafeSignal () {
            disconnect ();
            obj = null;
            id = null;
        }

        public void disconnect () {
            obj.disconnect (id);
        }
    }

    public ulong on_notify (Object obj, string prop, NotiftySignalHandler callback) {
        ulong id = obj.notify[prop].connect (() => {
            callback ();
        });
        
        callback ();

        return id;
    }

    public string to_title (string str) {
        return str.substring (0, 1).ascii_up () + str.substring (1);
    }

    public bool has_icon (string icon_name) {
        var theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
        return theme.has_icon (icon_name);
    }

    //  public 

    public Astal.Window get_window (Gtk.Widget self) {
        return (Astal.Window) self.get_root ();
    }
}