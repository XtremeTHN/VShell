public class Quick.Internet: Button {
    Network net;

    construct {
        net = new Network ();
        var icon = new NetworkIcon ();
        icon.tooltip_binding.unbind ();
        
        set_icon_widget (icon);

        net.bind_property ("tooltip-text", this, "body", BindingFlags.SYNC_CREATE);
    }
}