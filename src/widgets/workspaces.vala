class WorkspaceWidget : Adw.Bin {
    public int id { get; set; }
    bool _active = false;

    public WorkspaceWidget (int id) {
        Object ();

        this.id = id;
        set_valign (Gtk.Align.CENTER);
        set_halign (Gtk.Align.CENTER);
        add_css_class ("workspace");
    }

    public bool get_active () {
        return _active;
    }

    void set_class (string _class, bool active) {
        if (active)
            add_css_class (_class);
        else
            remove_css_class (_class);
    }

    public void set_no_anim (bool no_anim) {
        set_class ("no-anim", no_anim);
    }

    public void set_active (bool active) {
        set_class ("active", active);        
        _active = active;
    }
}

public class Workspaces : Gtk.Box {
    AstalHyprland.Hyprland hypr;

    List<WorkspaceWidget> _wk_list;

    construct {
        set_spacing (5);
        _wk_list = new List<WorkspaceWidget> ();
        hypr = AstalHyprland.Hyprland.get_default ();

        hypr.workspace_added.connect (on_new_workspace);
        hypr.workspace_removed.connect (on_remove_workspace);

        hypr.notify["focused-workspace"].connect (on_focus_change);

        foreach (var wk in hypr.workspaces) {
            on_new_workspace (null, wk);
        }
    }

    bool is_focused (WorkspaceWidget widget) {
        if (widget == null) return false;
        if (hypr.focused_workspace == null) return false;
        return widget.id == hypr.focused_workspace.id;
    }

    void on_focus_change () {
        foreach (var wk in _wk_list) {
            if (is_focused (wk)) {
                wk.set_active (true);
                continue;
            }

            if (wk.get_active ())
                wk.set_active (false);
        }
    }

    void on_new_workspace (AstalHyprland.Hyprland? obj, AstalHyprland.Workspace _workspace_data) {
        if (_workspace_data == null || _workspace_data.id <= 0)
            return;

        var wk = new WorkspaceWidget (_workspace_data.id);

        WorkspaceWidget? prev = null;
        int prev_pos = 0;
        
        for (int i = 0; i<_wk_list.length (); i++) {
            var existing_wk = _wk_list.nth_data (i);

            if (existing_wk == null) continue;

            if (existing_wk.id > _workspace_data.id) {
                break;
            }

            prev = existing_wk;
            prev_pos = i;
        }

        if (prev != null) {
            insert_child_after (wk, prev);
            _wk_list.insert (wk, prev_pos + 1); // insert after prev
        } else {
            prepend (wk);
            _wk_list.prepend (wk);
        }
    }

    void on_remove_workspace (AstalHyprland.Hyprland obj, int id) {
        foreach (var item in _wk_list) {
            if (item == null || item.id != id)
                continue;

            remove (item);
            _wk_list.remove (item);
            break;
        }
    }
}