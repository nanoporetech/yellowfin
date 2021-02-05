theme_dir = join_paths(get_option('prefix'), 'share', 'sounds', meson.project_name())

conf_data = configuration_data()
conf_data.merge_from(default_conf)

conf_data.set('ThemeName', meson.project_name())

configure_file(input : 'src/index.theme.in',
              output : 'index.theme',
              configuration : conf_data,
              install_dir: theme_dir)

install_subdir('src/stereo', install_dir: theme_dir)
