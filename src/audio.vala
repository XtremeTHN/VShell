[SingleInstance]
public class Audio: Object {
    AstalWp.Wp wp;

    public AstalWp.Endpoint? speaker { get; set; }

    construct {
        wp = AstalWp.get_default ();
        Utils.on_notify (wp, "audio", on_audio_changed);
    }

    void on_audio_changed () {
        var audio = wp.audio;

        if (audio == null) {
            warning ("Audio(): Wayplumber audio is null");
            speaker = null;
            return;
        }

        if (audio.default_speaker == null) {
            warning ("Audio(): No default speaker");
            speaker = null;
            return;
        }

        speaker = audio.default_speaker;
    }
}