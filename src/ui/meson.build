blueprints = custom_target(
  'blueprints',
  input: files(
    # LIST YOUR BLUEPRINT FILES HERE
    'bar.blp',
    'runner-app-item.blp',
    'runner.blp',
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