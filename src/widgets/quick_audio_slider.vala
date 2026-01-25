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

        audio.bind_property("icon-name", this, "icon-name", BindingFlags.SYNC_CREATE);
        audio.bind_property ("speaker", this, "speaker", BindingFlags.SYNC_CREATE);
    }
}