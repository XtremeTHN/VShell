public class Background: Astal.Window {
    public Background () {
        Object (
            namespace: "alert-background",
            layer: Astal.Layer.OVERLAY,
            anchor: Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT | Astal.WindowAnchor.TOP
        );

        add_css_class ("alert-background");
    }
}

[GtkTemplate (ui = "/com/github/XtremeTHN/VShell/alert-window.ui")]
public class AlertWindow: Astal.Window {
    Background back;

    public string heading { get; set; }
    public string body { get; set; }

    [GtkChild]
    public unowned Gtk.Box button_box;

    public AlertWindow () {
        Object (
            namespace: "alert-dialog",
            layer: Astal.Layer.OVERLAY
        );

        back = new Background ();
    }

    public new void present () {
        back.present ();
        base.present ();
    }

    public new void close () {
        back.close ();
        base.close ();
    }
}