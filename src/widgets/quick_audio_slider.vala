public class Quick.AudioSlider: Slider {
    Audio audio;
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

    construct {
        var icon = new AudioIcon ();
        audio = new Audio ();
        set_icon_widget (icon);

        audio.bind_property ("speaker", this, "speaker", BindingFlags.SYNC_CREATE);
    }
}