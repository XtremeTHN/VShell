vshell_sources = [
  'main.vala',
  'bar.vala',
  'circularprogress.vala',
  'barplayer.vala',
  'audioicon.vala',
  'networkicon.vala',
  'bluetoothicon.vala',
]

vshell_deps = [
  dependency('gtk4'),
  dependency('glib-2.0'),
  dependency('libnm'),
  dependency('gtk4-layer-shell-0'),
  dependency('astal-io-0.1'),
  dependency('astal-4-4.0'),
  dependency('astal-hyprland-0.1'),
  dependency('astal-mpris-0.1'),
  dependency('astal-wireplumber-0.1'),
  dependency('astal-network-0.1'),
  dependency('astal-bluetooth-0.1'),
  dependency('astal-cava-0.1'),
  dependency('astal-tray-0.1'),
  dependency('libadwaita-1', version: '>= 1.4'),
]

subdir('ui')
subdir('scss')

vshell_sources += gnome.compile_resources(
  'vshell-resources',
  'vshell.gresource.xml',
  dependencies: [blueprints, scss],
  c_name: 'vshell',
)

executable(
  'vshell',
  vshell_sources,
  dependencies: vshell_deps,
  install: true,
)