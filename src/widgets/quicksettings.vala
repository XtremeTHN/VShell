namespace Quick {
    [GtkTemplate (ui = "/com/github/XtremeTHN/VShell/quicksettings.ui")]
    public class Settings: Astal.Window {
        public Settings () {
            Object (
                anchor: Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.RIGHT,
                name: "quicksettings",
                namespace: "vshell-quicksettings",
                resizable: false,
                width_request: 400,
                margin: 10
            );
        }
    }

    public void register_types () {
        new ToggleButton ();
        new Button ();
        new Slider ();
        new Internet ();
        new Quick.Bluetooth ();
        new PowerMode ();
        new Tray ();
        new Settings ();
    }
}