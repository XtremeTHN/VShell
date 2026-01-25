public class Quick.PowerMode: Button {
    AstalPowerProfiles.PowerProfiles power;

    construct {
        button.is_locked = true;
        power = AstalPowerProfiles.get_default ();

        power.bind_property ("icon-name", this, "icon-name", BindingFlags.SYNC_CREATE);
        Utils.on_notify (power, "active-profile", on_active_changed);
    }

    void on_active_changed () {
        button.active = power.active_profile != "balanced";
        body = power.active_profile;
    }
}