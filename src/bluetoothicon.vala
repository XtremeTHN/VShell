public void bind_bluetooth (Gtk.Image icon) {
  var blue = AstalBluetooth.get_default ();

  blue.bind_property (
    "is-powered",
    icon,
    "icon-name",
    BindingFlags.SYNC_CREATE,
    (_, from, ref to) => {
      to.set_string (from.get_boolean () ? "bluetooth-symbolic" : "bluetooth-disabled-symbolic");
      return true;
    },
    null
  );
}
