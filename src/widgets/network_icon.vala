public class NetworkIcon: Adw.Bin {
    Gtk.Image image;
    Network net;

    public Binding tooltip_binding;
    public Binding icon_binding;

    construct {
        image = new Gtk.Image ();
        net = Network.get_instance ();

        tooltip_binding = net.bind_property (
            "tooltip-text",
            image,
            "tooltip-text",
            BindingFlags.SYNC_CREATE
        );

        icon_binding = net.bind_property (
            "icon-name",
            image,
            "icon-name",
            BindingFlags.SYNC_CREATE
        );

        set_child (image);
    }
}