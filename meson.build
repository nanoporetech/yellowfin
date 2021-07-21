project('Yellowfin',
        version: '20.04',
        meson_version: '>= 0.51',
        license : ['GPL3', 'CC BY-SA 4.0'],
        default_options: ['prefix=/usr'])
        


r=run_command('bash', '-c', 'sass debug_palette.scss')
colours = r.stderr().split('\n')

components = ['icons', 'gnome-shell', 'gtk', 'gtksourceview', 'sounds', 'sessions']

foreach component: components
  if not get_option(component)
    message('skip component ' + component)
    continue
  endif

#Setup colour data
  default_conf = configuration_data()
  foreach colour: colours
    colour = colour.split(':')
    if colour.length() == 4
      key = colour[2].strip()
      if key.endswith('color')
        default_conf.set(colour[2].strip(), colour[3].strip())
      endif
    endif
  endforeach

  message('build component ' + component)
  subdir(component)

endforeach

