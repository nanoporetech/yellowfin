#!/bin/bash

if [ ! "$(which sass 2> /dev/null)" ]; then
   echo sassc needs to be installed to generate the css.
   exit 1
fi

if [ ! "$(which git 2> /dev/null)" ]; then
   echo git needs to be installed to check GTK.
   exit 1
fi

SASSC_OPT="--no-source-map --style=compressed"

: ${GTK_SOURCE_PATH:="../../../gtk"}
: ${GTK_TAG:="3.24.23"}

if [ ! -d "${GTK_SOURCE_PATH}/gtk/theme/Adwaita" ]; then
   echo GTK sources not found at ${GTK_SOURCE_PATH}.
   exit 1
fi

# > /dev/null makes pushd and popd silent.
pushd ${GTK_SOURCE_PATH} > /dev/null
GTK_CURRENT_TAG=`git describe --tags`
popd > /dev/null

if [ "${GTK_CURRENT_TAG}" != "${GTK_TAG}" ]; then
   echo GTK must be at tag ${GTK_TAG}.
   exit 1
fi

sass $SASSC_OPT -I${GTK_SOURCE_PATH}/gtk/theme/Adwaita \
	Adwaita.scss Adwaita.css
sass $SASSC_OPT -I${GTK_SOURCE_PATH}/gtk/theme/Adwaita \
	Adwaita-dark.scss Adwaita-dark.css
sass $SASSC_OPT -I${GTK_SOURCE_PATH}/gtk/theme/Adwaita \
	fallback.scss fallback.css
sass $SASSC_OPT -I${GTK_SOURCE_PATH}/gtk/theme/Adwaita -I${GTK_SOURCE_PATH}/gtk/theme/HighContrast \
	HighContrast.scss HighContrast.css
sass $SASSC_OPT -I${GTK_SOURCE_PATH}/gtk/theme/Adwaita -I${GTK_SOURCE_PATH}/gtk/theme/HighContrast \
	HighContrastInverse.scss HighContrastInverse.css
sass $SASSC_OPT -I${GTK_SOURCE_PATH}/gtk/theme/Adwaita \
	shared.scss shared.css
