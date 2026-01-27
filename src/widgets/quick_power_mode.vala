public class Quick.PowerModeMenu: Menu {
    AstalPowerProfiles.PowerProfiles power;

    public PowerModeMenu () {
        Object ();
        power = AstalPowerProfiles.get_default ();

        heading = "Power Profiles";
        icon_name = "power-profile-performance-symbolic";
        placeholder_icon_name = icon_name;
        placeholder_title = "No profiles available";
        has_end_buttons = false;

        Gtk.ToggleButton? prev = null;
        foreach (var x in power.profiles) {
            var btt = new_button (x);

            if (prev != null)
                btt.set_group (prev);
            
            prev = btt;
        }

        if (prev != null)
            stack.set_visible_child_name ("main");
    }

    Gtk.ToggleButton new_button (AstalPowerProfiles.Profile profile) {
        var btt = new Gtk.ToggleButton ();
        btt.add_css_class ("flat");
        var cnt = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);

        var icon = new Gtk.Image ();
        icon.set_from_icon_name (@"power-profile-$(profile.profile)-symbolic");
        
        var label = new Gtk.Label (Utils.to_title (profile.profile).replace ("-", " "));

        cnt.append (icon);
        cnt.append (label);

        btt.set_child (cnt);

        btt.set_data<string> ("profile", profile.profile);

        btt.clicked.connect (change_power_profile);

        listbox.append (btt);

        return btt;
    }

    void change_power_profile (Gtk.Button btt) {
        string? profile = btt.get_data<string> ("profile");
        if (profile == null)
            return;

        power.active_profile = profile;
    }
}

public class Quick.PowerMode: Button {
    AstalPowerProfiles.PowerProfiles power;

    construct {
        power = AstalPowerProfiles.get_default ();
        menu = new PowerModeMenu ();

        power.bind_property ("icon-name", this, "icon-name", BindingFlags.SYNC_CREATE);
        power.notify["active-profile"].connect (on_active_changed);

        on_active_changed ();
    }

    void on_active_changed () {
        button.active = power.active_profile != "balanced";
        body = Utils.to_title (power.active_profile.replace ("-", " "));
    }
}