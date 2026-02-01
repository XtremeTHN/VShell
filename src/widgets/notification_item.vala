[GtkTemplate (ui = "/com/github/XtremeTHN/VShell/notification.ui")]
public class Notification: Gtk.ListBoxRow {
    public string app_icon { get; set; }
    public string app_name { get; set; }
    public string timestamp { get; set; }
    public Gdk.Paintable image_paintable { get; set; }

    public string heading { get; set; }
    public string body { get; set; }

    public bool has_image { get; set; }
    public bool reveal_actions { get; set; }
    public bool shell_expired { get; set; }

    [GtkChild]
    unowned Gtk.Box actions_box;

    [GtkChild]
    unowned Gtk.Box middle_box;

    [GtkChild]
    unowned Gtk.Frame frame;

    AstalNotifd.Notification noti;
    Gtk.EventControllerMotion motion;

    public signal void shell_expire ();

    public Notification (AstalNotifd.Notification noti, uint shell_expire_time) {
        Object ();

        this.noti = noti;
        app_name = noti.app_name;

        heading = noti.summary;
        body = noti.body;

        motion = new Gtk.EventControllerMotion ();
        add_controller (motion);

        motion.enter.connect (on_enter);
        motion.leave.connect (on_leave);

        var theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
        if (theme.has_icon (noti.app_icon))
            app_icon = noti.app_icon;
        else
            app_icon = "application-x-executable-symbolic";

        
        if (noti.image != "")
            try {
                var image = File.new_for_path (noti.image);
                image_paintable = Gdk.Texture.from_file (image);
            } catch (Error e) {
                var image = new Gtk.Image ();
                image.set_icon_size (Gtk.IconSize.LARGE);
                middle_box.remove (frame);
                middle_box.prepend (image);
                image.set_from_icon_name (noti.image);                
            } finally {
                has_image = true;
            }

        if (noti.actions.length () == 0)
            return;
        
        noti.actions.foreach (new_action);

        Timeout.add (shell_expire_time, () => {
            emit_shell_expired ();
            return Source.REMOVE;
        });
    }
    
    [GtkCallback]
    void dismiss () {
        noti.dismiss ();
    }

    void emit_shell_expired () {
        shell_expire ();
        shell_expired = true;
    }

    void on_enter (Gtk.EventControllerMotion _, double x, double y) {
        if (shell_expired) return;
        if (noti.actions.length () == 0) return;

        reveal_actions = true;
    }

    void on_leave (Gtk.EventControllerMotion cont) {
        if (shell_expired) return;
        if (noti.actions.length () == 0) return;
        
        reveal_actions = false;
        emit_shell_expired ();
    }
    
    [GtkCallback]
    void toggle_reveal_actions () {
        reveal_actions = !reveal_actions;
    }

    void new_action (AstalNotifd.Action action) {
        var btt = new Gtk.Button ();
        btt.set_label (action.label);
        btt.clicked.connect (() => {
            noti.invoke (action.id);
        });

        actions_box.append (btt);
    }
}