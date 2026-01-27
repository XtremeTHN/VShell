public class Quick.AudioMenu: Menu {
    public AudioMenu () {
        Object ();

        var audio = new Audio ();

        icon_name = "audio-headphones-symbolic";
        heading = "Audio mixer";

        placeholder_icon_name = icon_name;
        placeholder_title = "No streams available";
        has_end_buttons = false;

        listbox.set_css_classes ({"boxed-list"});
        set_model (audio.streams_model, new_stream);
    }

    Gtk.Widget new_stream (Object obj) {
        // TODO: make this a blueprint file
        var stream = (AstalWp.Stream) obj;
        var widget = new Adw.ActionRow ();

        var content = new Gtk.CenterBox ();
        
        content.add_css_class ("box-10");

        var label = new Gtk.Label (stream.description);
        label.set_max_width_chars (10);
        label.set_hexpand (true);
        label.set_xalign (0);
        label.set_ellipsize (Pango.EllipsizeMode.END);
        content.set_start_widget (label);
        
        var end_widget = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
        end_widget.set_halign (Gtk.Align.END);
        var button = new Gtk.Button ();
        button.add_css_class ("flat");
        stream.bind_property ("volume-icon", button, "icon-name", BindingFlags.SYNC_CREATE);
        end_widget.append(button);

        button.clicked.connect (() => {
            stream.mute = !stream.mute;
        });

        var adjustment = new Gtk.Adjustment (0, 0, 1, 0.01, 0.01, 0.1);
        var scale = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, adjustment);
        scale.set_size_request (130, -1);
        scale.set_hexpand (true);

        stream.bind_property ("volume", adjustment, "value", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
        end_widget.append (scale);

        content.set_end_widget (end_widget);
        
        widget.set_child (content);

        return widget;
    }
}

public class Quick.AudioSlider: Slider {
    Audio audio;
    AstalWp.Endpoint? _speaker;
    public AstalWp.Endpoint? speaker {
        get {
            return _speaker;
        }
        set {
            _speaker = value;

            if (_speaker == null) {
                scale.set_sensitive (false);
                return;
            }

            _speaker.bind_property (
                "volume",
                scale.adjustment,
                "value",
                BindingFlags.BIDIRECTIONAL,
                (b,fv, ref tv) => {
                    tv.set_double (fv.get_double () * 100);
                    return true;
                },
                (b, fv, ref tv) => {
                    tv.set_double (fv.get_double () / 100);
                    return true;
                }
            );
        
            scale.set_sensitive (true);
        }
    }

    construct {
        audio = new Audio ();
        menu = new AudioMenu ();

        audio.bind_property("icon-name", this, "icon-name", BindingFlags.SYNC_CREATE);
        audio.bind_property ("speaker", this, "speaker", BindingFlags.SYNC_CREATE);
    }
}