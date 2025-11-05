using Gtk;

[GtkTemplate (ui = "/com/github/XtremeTHN/VShell/bar.ui")]
public class VShell.Bar : Astal.Window {
  [GtkChild]
  unowned Label active_workspace;

  [GtkChild]
  unowned Label active_window;

  [GtkChild]
  unowned Label music_title;

  [GtkChild]
  unowned Revealer rev;

  [GtkChild]
  unowned Label date;

  [GtkChild]
  unowned Box tray;

  [GtkChild]
  unowned Image prog;

  [GtkChild]
  unowned Image audio_icon;

  [GtkChild]
  unowned Image network_icon;

  [GtkChild]
  unowned Image bluetooth_icon;

  AstalHyprland.Hyprland hypr;

  public Bar () {
    Object (anchor: Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT, name: "bar", namespace: "vshell-bar", exclusivity: Astal.Exclusivity.EXCLUSIVE);

    add_css_class ("bar-window");

    hypr = AstalHyprland.get_default ();

    hypr.notify["focused-client"].connect (change_client);
    hypr.notify["focused-workspace"].connect (change_workspace);

    change_client ();
    change_workspace ();
    
    init_widgets();
  }

  void init_widgets () {
    var paint = new CircularProgressPaintable ();
    paint.widget = prog;
    prog.set_from_paintable (paint);

    new BarPlayer (rev, paint, music_title);
    new Speaker (audio_icon);

    Timeout.add_seconds (1, change_date, Priority.DEFAULT);

    bind_bluetooth (bluetooth_icon);
    bind_net (network_icon);
  }

  bool change_date () {
    var d = new DateTime.now_local ();
    date.set_label (d.format ("%I:%M %p %a %b %Y"));

    return true;
  }

  void change_workspace () {
    var wksp = hypr.focused_workspace;

    if (wksp == null)
      return;

    active_workspace.set_label ("Workspace " + wksp.id.to_string ());
  }

  void change_client () {
    var client = hypr.focused_client;

    if (client == null) {
      active_window.set_label ("NixOS");
      return;
    }

    client.bind_property ("title", active_window, "label", BindingFlags.SYNC_CREATE, null, null);
  }
}
