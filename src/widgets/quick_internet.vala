public class Quick.Internet: Button {
    Network net;

    construct {
        net = new Network ();
        var icon = new NetworkIcon ();
        icon.tooltip_binding.unbind ();
        
        set_icon_widget (icon);

        net.bind_property ("tooltip-text", this, "body", BindingFlags.SYNC_CREATE);
        net.bind_property ("active", this.button, "active", BindingFlags.SYNC_CREATE);

        button.clicked.connect (on_click);

        //  show_menu.connect (on_show);
    }

    void on_click () {
        net.active = !net.active;
    }
}