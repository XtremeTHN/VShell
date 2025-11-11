void on_tooltip_change (AstalBluetooth.Adapter? adapter, Gtk.Image icon) {
    if (adapter == null) {
      icon.set_visible (false);
      return;
    }

    icon.set_visible (true);
    icon.set_tooltip_text (adapter.powered ? "Enabled" : "Disabled");
}

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

  blue.notify["adapter"].connect (() => {
    on_tooltip_change (blue.adapter, icon);
  });

  on_tooltip_change (blue.adapter, icon);
}
