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
    public Gtk.Image image;
    Audio audio;

    public bool _has_tooltip = true;

    construct {
        audio = new Audio ();
        image = new Gtk.Image ();

        Utils.on_notify (audio, "speaker", on_speaker_change);

        set_child (image);
    }

    bool to_percentage (Binding _, Value from, ref Value to) {
        to.set_string ((from.get_double () * 100).to_string () + "%");
        return true;
    }

    void on_speaker_change () {
        if (_has_tooltip)
            audio.speaker.bind_property ("volume", image, "tooltip-text", BindingFlags.SYNC_CREATE, to_percentage, null);
        audio.speaker.bind_property ("volume-icon", image, "icon-name", BindingFlags.SYNC_CREATE, null, null);
    }
}