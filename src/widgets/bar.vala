using Gtk;

[GtkTemplate (ui = "/com/github/XtremeTHN/VShell/bar.ui")]
public class Bar : Astal.Window {
  public Bar () {
    Object (anchor: Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT, name: "bar", namespace: "vshell-bar", exclusivity: Astal.Exclusivity.EXCLUSIVE);

    add_css_class ("bar-window");

    //  init_widgets();
  }
  
  //  void init_widgets () {
  //    Timeout.add_seconds (1, change_date, Priority.DEFAULT);
  //  }

  //  bool change_date () {
  //    var d = new DateTime.now_local ();
  //    date.set_label (d.format ("%I:%M %p %a %b %Y"));

  //    return true;
  //  }
}