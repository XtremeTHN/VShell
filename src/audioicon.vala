public class VShell.Speaker {
  AstalWp.Audio audio;
  Gtk.Image icon;
  AstalWp.Wp wp;

  public Speaker (Gtk.Image icon) {
    wp = AstalWp.get_default ();
    this.icon = icon;

    wp.notify["audio"].connect (on_audio_obj_change);
    on_audio_obj_change ();
  }

  bool to_percentage (Binding _, Value from, ref Value to) {
    to.set_string ((from.get_double () * 100).to_string ());
    return true;
  }

  void on_audio_obj_change () {
    audio = wp.audio;

    if (audio == null) {
      warning ("Audio is null. Not binding icon");
      return;
    }

    if (audio.default_speaker == null) {
      warning ("No default speaker");
      icon.set_from_icon_name ("audio-volume-muted-symbolic");
      return;
    }

    audio.default_speaker.bind_property ("volume", icon, "tooltip-text", BindingFlags.SYNC_CREATE, to_percentage, null);

    audio.default_speaker.bind_property ("volume-icon", icon, "icon-name", BindingFlags.SYNC_CREATE, null, null);
  }
}
