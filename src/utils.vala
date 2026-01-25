namespace Utils {
    public delegate void NotiftySignalHandler ();

    public void on_notify (Object obj, string prop, NotiftySignalHandler callback) {
        obj.notify[prop].connect (() => {
            callback ();
        });
        
        callback ();
    }

    public string to_title (string str) {
        return str.substring (0, 1).ascii_up () + str.substring (1);
    }
}