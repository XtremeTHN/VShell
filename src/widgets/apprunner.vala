using Gtk;

errordomain AppItemErrors {
    UNSUPPORTED_TYPE
}

enum Direction {
    UP,
    DOWN
}

[GtkTemplate (ui = "/com/github/XtremeTHN/VShell/runner-app-item.ui")]
public class AppItem : ListBoxRow {
    [GtkChild]
    unowned Image app_icon;

    [GtkChild]
    unowned Label app_name;

    [GtkChild]
    unowned Label app_description;

    [GtkChild]
    unowned Image app_type_icon;

    public AstalApps.Application info;

    public AppItem (AstalApps.Application app_info) throws Error {
        Object ();
        info = app_info;

        var theme = IconTheme.get_for_display (Gdk.Display.get_default ());
        
        if (theme.has_icon (app_info.icon_name))
            app_icon.set_from_icon_name (app_info.icon_name);
        else try {
            app_icon.set_from_paintable (Gdk.Texture.from_filename (app_info.icon_name));
        } catch (Error e) {
            warning ("Couldn't get icon for entry: %s. %s", app_info.entry, e.message);
            app_icon.set_from_icon_name ("image-missing");
        }
        
        app_name.set_label (app_info.name);

        if (app_info.description != null)
            app_description.set_label (app_info.description);
        else
            app_description.set_visible (false);
        
        var type = new DesktopAppInfo (app_info.entry);

        string _app_type;
        switch (type.get_string ("Type")) {
            case "Application":
                _app_type = "application-x-executable-symbolic";
                break;
            case "Link":
                _app_type = "external-link-symbolic";
                break;
            case "Directory":
                _app_type = "folder-symbolic";
                break;
            default:
                throw new AppItemErrors.UNSUPPORTED_TYPE ("Unsupported type: " + type.get_string ("Type"));
        }

        app_type_icon.set_from_icon_name (_app_type);
    }
}

[GtkTemplate (ui = "/com/github/XtremeTHN/VShell/runner.ui")]
public class VShell.AppRunner : Astal.Window {
    [GtkChild]
    unowned SearchEntry search_entry;

    [GtkChild]
    unowned Revealer rev;

    [GtkChild]
    unowned ScrolledWindow scrolled;

    [GtkChild]
    unowned Viewport viewport;

    [GtkChild]
    unowned ListBox app_box;

    bool empty = true;
    AstalApps.Apps apps;

    public AppRunner () {
        Object (
            name: "app-runner",
            keymode: Astal.Keymode.ON_DEMAND,
            namespace: "vshell-app-runner",
            resizable: false
        );

        add_css_class ("adwaita-window");
        apps = new AstalApps.Apps ();

        search_entry.set_key_capture_widget (this);
        notify["visible"].connect (on_visible_change);
    }

    void on_visible_change () {
        if (get_visible () == false) {
            rev.set_reveal_child (false);
            search_entry.set_text ("");
        } else {
            apps.reload ();
            search_entry.grab_focus ();
        }

        app_box.remove_all ();
    }

    void launch_row (ListBoxRow? app_row) {
        if (app_row == null) return;
        var row = (AppItem) app_row;

        row.info.launch ();
        hide_window ();
    }

    [GtkCallback]
    void launch_from_search () {
        if (empty) return;
        launch_row (app_box.get_selected_row ());
    }

    [GtkCallback]
    void launch_from_box (Object _, ListBoxRow raw_row) {
        launch_row (raw_row);
    }

    void navigate (Direction direction) {
        var row = app_box.get_selected_row ();

        if (row == null) return;

        Widget? next_row = null;

        if (direction == Direction.UP)
            next_row = row.get_prev_sibling ();
        else if (direction == Direction.DOWN)
            next_row = row.get_next_sibling ();

        if (next_row != null) {
            app_box.select_row ((ListBoxRow) next_row);
            viewport.scroll_to (next_row, null);
        }
    }

    [GtkCallback]
    void next_app () {
        navigate (Direction.DOWN);
    }

    [GtkCallback]
    void prev_app () {
        navigate (Direction.UP);
    }

    [GtkCallback]
    void query () {
        var q = search_entry.get_text ();

        if (q.length == 0) {
            rev.set_reveal_child (false);
            return;
        }

        rev.set_reveal_child (true);

        var result = apps.fuzzy_query (q);
        app_box.remove_all ();

        empty = result.is_empty ();

        foreach (var x in result) try {
            var item = new AppItem (x);
            app_box.append (item);
        } catch (Error e) {
            continue;
        }

        app_box.select_row ((ListBoxRow) app_box.get_first_child ());
    }

    [GtkCallback]
    void hide_window () {
        set_visible (false);
    }
}