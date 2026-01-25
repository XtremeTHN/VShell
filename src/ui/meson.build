blueprints = custom_target(
  'blueprints',
  input: files(
    # LIST YOUR BLUEPRINT FILES HERE
    'bar.blp',
    'music.blp',
    'runner.blp',
    'quicksettings.blp',
    'quick-slider.blp',
    'quick-button.blp',
    'runner-app-item.blp',
  ),
  output: '.',
  command: [
    find_program('blueprint-compiler'),
    'batch-compile',
    '@OUTPUT@',
    '@CURRENT_SOURCE_DIR@',
    '@INPUT@',
  ],
)