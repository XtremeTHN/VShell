[GtkTemplate (ui = "/com/github/XtremeTHN/VShell/quick-battery.ui")]
public class Quick.Battery: Gtk.Box {
    [GtkChild]
    unowned Gtk.Image battery_icon;

    [GtkChild]
    unowned Gtk.Label battery_percentage;

    AstalBattery.Device battery;

    construct {
        battery = AstalBattery.get_default ();

        if (battery == null || battery.device_type != AstalBattery.Type.BATTERY || battery.power_supply == false) {
            battery_icon.set_from_icon_name ("nix-symbolic");
            battery_percentage.set_label ("NixOS");
            return;
        }
        
        battery.bind_property("battery-icon-name", battery_icon, "icon-name", BindingFlags.SYNC_CREATE);
        battery.bind_property("percentage", battery_percentage, "label", BindingFlags.SYNC_CREATE, (b, from, ref to) => {
            to.set_string ("%f%%".printf(Math.floor(from.get_double () * 100)));
            return true;
        });
    }
}