[GtkTemplate (ui = "/com/github/XtremeTHN/VShell/quick-menu.ui")]
public class Quick.Menu: Dialog {
    [GtkChild]
    public unowned Gtk.Stack stack;
    
    [GtkChild]
    public unowned Gtk.ListBox listbox;

    [GtkChild]
    public unowned Gtk.Separator sep;

    [GtkChild]
    public unowned Gtk.Box end_box;

    public string icon_name { get; set; }
    public string heading { get; set; }

    public string placeholder_icon_name { get; set; }
    public string placeholder_title { get; set; }
    public string placeholder_description { get; set; }

    public bool has_end_buttons {
        set {
            end_box.visible = value;
            sep.visible = value;
        }
    }


    public void set_model (ListModel model, Gtk.ListBoxCreateWidgetFunc new_widget) {
        listbox.bind_model (model, new_widget);
        model.items_changed.connect (on_item_change);
    }

    void on_item_change (ListModel model, uint pos, uint removed, uint added) {
        if (model.get_n_items () == 0)
            stack.set_visible_child_name ("placeholder");
        else
            stack.set_visible_child_name ("main");
    }

    public void pack_end (Gtk.Widget widget) {
        var empty = end_box.get_first_child () == null;
        sep.set_visible (!empty);
        end_box.set_visible (!empty);

        end_box.append (widget);
    }
}