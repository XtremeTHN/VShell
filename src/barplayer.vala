public class VShell.BarPlayer {
  CircularProgressPaintable progress;
  Gtk.Label title;
  AstalMpris.Player player;
  Gtk.Revealer rev;

  public BarPlayer (Gtk.Revealer rev, CircularProgressPaintable progress, Gtk.Label title) {
    this.progress = progress;
    this.title = title;
    this.rev = rev;
  
    player = new AstalMpris.Player ("spotify"); // TODO: make this configurable
  
    player.bind_property ("position", progress, "fraction", BindingFlags.SYNC_CREATE, to_fraction, null);
    player.bind_property ("title", title, "label", BindingFlags.SYNC_CREATE, null, null);

    player.notify["available"].connect (on_available);
    on_available ();
  }

  void on_available () {
    rev.set_reveal_child (player.available);
  }

  bool to_fraction (Binding _, Value from, ref Value to) {
    var prog = from.get_double ();

    if (prog > 0)
      to.set_double (from.get_double () / player.length);
    else
      return false;
    return true;
  }
}
