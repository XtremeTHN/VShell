public class NotificationList: Astal.Window {
    AstalNotifd.Notifd notifd;
    Gee.HashMap<uint, Notification> notifications;
    Gtk.ListBox box;

    public NotificationList () {
        Object (
            namespace: "vshell-notifications",
            anchor: Astal.WindowAnchor.BOTTOM,
            layer: Astal.Layer.OVERLAY,
            resizable: false
        );

        notifd = AstalNotifd.Notifd.get_default ();
        notifications = new Gee.HashMap<uint, Notification> ();

        box = new Gtk.ListBox ();
        box.add_css_class ("boxed-list-separate");
        box.add_css_class ("notification-list");
        
        box.width_request = 400;

        notifd.notified.connect (on_notified);
        notifd.resolved.connect (on_resolved);

        set_child (box);
        set_css_classes ({});
    }

    Notification remove_notification (uint id) {
        Notification n = notifications.get (id);

        box.remove (n);
        notifications.unset (id);

        return n;
    }

    void on_resolved (uint id, AstalNotifd.ClosedReason reason) {
        if (!notifications.has_key (id))
            return;

        remove_notification (id);

        if (box.get_first_child () == null)
            set_visible (false);
    }

    void on_notified (uint id, bool replace) {
        set_visible (true);

        var n = notifd.get_notification (id);
        var widget = new Notification (n, 10000);

        if (replace) {
            remove_notification (id);
            //  on_resolved (id, AstalNotifd.ClosedReason.UNDEFINED);
        }

        notifications[id] = widget;

        box.prepend (widget);
    }
}