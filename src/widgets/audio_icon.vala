// TODO: remove this if the quicksettings window is going to be implemented
class AudioController: Gtk.Popover {
    Gtk.Scale scale;

    AstalWp.Endpoint? _speaker;
    public AstalWp.Endpoint? speaker {
        get {
            return _speaker;
        }
        set {
            _speaker = value;

            if (_speaker != null)
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
            
            scale.set_sensitive (_speaker != null);
        }
    }


    public AudioController () {
        Object ();
        add_css_class ("box-10");

        scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 150, 1);

        scale.add_mark (100, Gtk.PositionType.TOP, null);
        set_child (scale);

        width_request = 200;
    }
}

public class AudioIcon: Adw.Bin {
    AudioController pop;
    Gtk.Image image;
    AstalWp.Wp wp;

    construct {
        pop = new AudioController ();
        pop.set_has_arrow (false);
        wp = AstalWp.get_default ();

        var click = new Gtk.GestureClick ();
        click.released.connect (on_click);

        image = new Gtk.Image ();

        image.add_controller (click);

        Utils.on_notify (wp, "audio", on_audio_obj_change);

        set_child (image);
        pop.set_parent (this);
    }

    void on_click (Gtk.GestureClick obj, int n_press, double x, double y) {
        pop.popup ();
    }

    bool to_percentage (Binding _, Value from, ref Value to) {
        to.set_string ((from.get_double () * 100).to_string () + "%");
        return true;
    }

    void on_audio_obj_change () {
        var audio = wp.audio;

        if (audio == null) {
            warning ("Audio is null. Not binding icon");
            pop.speaker = null;
            return;
        }

        pop.speaker = audio.default_speaker;

        if (audio.default_speaker == null) {
            warning ("No default speaker");
            image.set_from_icon_name ("audio-volume-muted-symbolic");
            return;
        }

        audio.default_speaker.bind_property ("volume", image, "tooltip-text", BindingFlags.SYNC_CREATE, to_percentage, null);
        audio.default_speaker.bind_property ("volume-icon", image, "icon-name", BindingFlags.SYNC_CREATE, null, null);
    }
}