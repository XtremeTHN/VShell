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

    public AstalNotifd.Notification noti;
    Gtk.EventControllerMotion motion;

    public delegate void OnExpire (Notification n);

    public bool update_stamps { get; set; default = true; }

    OnExpire cb;
    uint timeout;

    public Notification (AstalNotifd.Notification noti, uint shell_expire_time, OnExpire cb) {
        Object ();

        this.cb = cb;
        this.noti = noti;
        app_name = noti.app_name;

        heading = noti.summary;
        body = noti.body;

        timestamp = format_stamp ();

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

        if (noti.actions.length () != 0)
            noti.actions.foreach (new_action);
        
        timeout = Timeout.add (shell_expire_time, () => {
            emit_shell_expired ();
            timeout = 0;
            return false;
        });
    }

    void schedule_stamp_update (uint seconds) {
        if (!update_stamps) return;

        Timeout.add_seconds (seconds, () => {
            format_stamp ();
            return Source.REMOVE;
        });
    }

    string stamp_string (double diff, string unit) {
        var rounded = (int) diff;
        return @"$rounded $unit ago";
    }

    string format_stamp () {
        var time = noti.time;
        if (time < 30) {
            schedule_stamp_update (30);
            return "Just now";
        }
        
        if (time < 60) {
            schedule_stamp_update (10);
            return stamp_string (time, "seconds");
        }

        if (time < 3600) {
            schedule_stamp_update (60);
            return stamp_string (time / 60, "minutes");
        }

        if (time < 86400) {
            schedule_stamp_update (3600);
            return stamp_string (time / 3600, "hours");
        }
        
        if (time < 604800)
            return stamp_string (time / 86400, "days");

        if (time < 2592000)            
            return stamp_string (time / 604800, "weeks");

        if (time < 31536000)
            return stamp_string (time / 2592000, "months"); // idk if this one is necessary
        return stamp_string (time / 31536000, "years"); // this one too
    }

    public void cancel_timeout () {
        if (timeout > 0)
            Source.remove (timeout);
    }

    void emit_shell_expired () {
        cb (this);
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
    void dismiss () {
        cancel_timeout ();
        noti.dismiss ();
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