public class NotificationWindow: Astal.Window {
    NotificationList list;

    public NotificationWindow () {
        Object (
            namespace: "vshell-notifications",
            anchor: Astal.WindowAnchor.BOTTOM,
            layer: Astal.Layer.OVERLAY,
            resizable: false,
            margin_bottom: 10
        );

        var box = new Gtk.ListBox ();
        box.add_css_class ("boxed-list-separate");
        box.add_css_class ("notification-list");
        
        box.width_request = 400;

        list = new NotificationList (box);

        box.bind_model (list.store, new_row);

        list.bind_property ("visible", this, "visible", BindingFlags.SYNC_CREATE);

        set_child (box);
        set_css_classes ({});
    }

    Gtk.Widget new_row (Object? notif) {
        return new Notification (notif as AstalNotifd.Notification, 5000, (n) => {
            list.remove_notification (n.noti.id);
        });
    }
}