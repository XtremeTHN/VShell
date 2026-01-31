public class Quick.Internet: Button {
    Network net;

    construct {
        net = Network.get_instance ();
        net.bind_property ("icon-name", this, "icon-name", BindingFlags.SYNC_CREATE);

        net.bind_property ("tooltip-text", this, "body", BindingFlags.SYNC_CREATE);
        net.bind_property ("active", this.button, "active", BindingFlags.SYNC_CREATE);

        button.clicked.connect (on_click);
        //  show_menu.connect (on_show);
    }

    void on_click () {
        net.active = !net.active;
    }
}