namespace Utils {
    public delegate void NotiftySignalHandler ();

    public void on_notify (Object obj, string prop, NotiftySignalHandler callback) {
        obj.notify[prop].connect (() => {
            callback ();
        });
        
        callback ();
    }
}