[SingleInstance]
public class Audio: Object {
    AstalWp.Wp wp;

    public ListStore streams_model { get; set; }
    public AstalWp.Endpoint? speaker { get; set; }

    public string icon_name { get; set; }
    public double volume { get; set; }

    construct {
        wp = AstalWp.get_default ();
        streams_model = new ListStore (typeof (AstalWp.Stream));
        Utils.on_notify (wp, "audio", on_audio_changed);
    }

    void on_audio_changed () {
        var audio = wp.audio;

        if (audio == null) {
            warning ("Audio(): Wayplumber audio is null");
            speaker = null;
            streams_model.remove_all ();
            return;
        }

        if (audio.default_speaker == null) {
            warning ("Audio(): No default speaker");
            speaker = null;
            return;
        }

        speaker = audio.default_speaker;

        speaker.bind_property ("volume", this, "volume", BindingFlags.SYNC_CREATE);
        speaker.bind_property ("volume-icon", this, "icon-name", BindingFlags.SYNC_CREATE);

        audio.stream_added.connect (on_stream_add);
        audio.stream_removed.connect (on_stream_remove);
    }

    void on_stream_add (AstalWp.Audio audio, AstalWp.Stream stream) {
        streams_model.append (stream);
    }

    void on_stream_remove (AstalWp.Audio audio, AstalWp.Stream stream) {
        uint? pos = null;
        streams_model.find (stream, out pos);

        if (pos == null) {
            warning ("stream not in model: %s", stream.name);
            return;
        };

        streams_model.remove (pos);
    }
}