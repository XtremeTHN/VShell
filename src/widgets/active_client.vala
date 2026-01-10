public class ActiveClient: Adw.Bin {
    AstalHyprland.Hyprland? hypr;
    Gtk.Label label;

    construct {
        label = new Gtk.Label ("NixOS"); // TODO: make this configurable
        hypr = AstalHyprland.Hyprland.get_default ();
    
        assert (hypr != null);

        hypr.notify["focused-client"].connect (change_label);

        set_child (label);
    }

    void change_label () {
        if (hypr.focused_client != null)
            hypr.focused_client.bind_property ("title", label, "label", GLib.BindingFlags.SYNC_CREATE, null, null);
        else
            label.set_label ("NixOS");
    }
}