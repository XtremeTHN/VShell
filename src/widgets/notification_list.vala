// I'm not proud of this implementation
public class NotificationList: Object {
    public bool visible { get; set; }
    public ListStore store;

    AstalNotifd.Notifd notifd;
    Gtk.ListBox box;

    public NotificationList (Gtk.ListBox box) {
        Object ();

        this.box = box; 
        notifd = AstalNotifd.Notifd.get_default ();
        store = new ListStore (typeof (AstalNotifd.Notification));

        notifd.notified.connect (on_notified);
        notifd.resolved.connect (on_resolved);
    }

    int get_notification_index (uint id) {
        int index = -1;
        for (int i = 0; i<store.get_n_items (); i++) {
            var item = store.get_object (i) as AstalNotifd.Notification;
            if (item.id == id) {
                index = i;
                break;
            };
        }

        return index;
    }

    public uint remove_notification (uint id, bool hide_if_empty = true) {
        var index = get_notification_index (id);

        bool found = index >= 0;
        if (found) {
            var r = box.get_row_at_index (index) as Notification;
            r.cancel_timeout ();

            store.remove (index);
        }

        if (store.get_n_items () == 0 && hide_if_empty)
            visible = false;
        
        return found ? index : 0;
    }

    void on_resolved (uint id, AstalNotifd.ClosedReason reason) {
        remove_notification (id);
    }

    void on_notified (uint id, bool replace) {
        visible = true;
        var n = notifd.get_notification (id);

        uint index = 0;
        if (replace)
            index = remove_notification (id, false);
        else {
            index = store.get_n_items ();
        }

        store.insert (index, n);
    }
}