public class NotificationList: Astal.Window {
    AstalNotifd.Notifd notifd;
    ListStore store;
    Gtk.ListBox box;

    public NotificationList () {
        Object (
            namespace: "vshell-notifications",
            anchor: Astal.WindowAnchor.BOTTOM,
            layer: Astal.Layer.OVERLAY,
            resizable: false,
            margin_bottom: 10
        );

        notifd = AstalNotifd.Notifd.get_default ();
        store = new ListStore (typeof (AstalNotifd.Notification));

        box = new Gtk.ListBox ();
        box.add_css_class ("boxed-list-separate");
        box.add_css_class ("notification-list");
        
        box.width_request = 400;

        box.bind_model (store, new_row);

        notifd.notified.connect (on_notified);
        notifd.resolved.connect (on_resolved);

        set_child (box);
        set_css_classes ({});
    }


    Gtk.Widget new_row (Object? notif) {
        return new Notification (notif as AstalNotifd.Notification, 5000, (n) => {
            remove_notification (n.noti.id);
        });
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

    uint remove_notification (uint id, bool hide_if_empty = true) {
        var index = get_notification_index (id);

        bool found = index >= 0;
        if (found) {
            var r = box.get_row_at_index (index) as Notification;
            r.cancel_timeout ();

            store.remove (index);
        }

        if (store.get_n_items () == 0 && hide_if_empty)
            set_visible (false);
        
        return found ? index : 0;
    }

    void on_resolved (uint id, AstalNotifd.ClosedReason reason) {
        remove_notification (id);
    }

    void on_notified (uint id, bool replace) {
        set_visible (true);
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