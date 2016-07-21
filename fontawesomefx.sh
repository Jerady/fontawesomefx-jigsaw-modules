#!/bin/bash

APP_TITLE="FontAwesomeFX-app"

print_header() {
cat <<EOF

 ______          _                                                   ________   __
|  ____|        | |     /\                                          |  ____\ \ / /
| |__ ___  _ __ | |_   /  \__      _____  ___  ___  _ __ ___   ___  | |__   \ V /
|  __/ _ \| '_ \| __| / /\ \ \ /\ / / _ \/ __|/ _ \| '_ ' _ \ / _ \ |  __|   > <
| | | (_) | | | | |_ / ____ \ V  V /  __/\__ \ (_) | | | | | |  __/ | |     / . \\
|_|  \___/|_| |_|\__/_/    \_\_/\_/ \___||___/\___/|_| |_| |_|\___| |_|    /_/ \_\\

EOF
print_blue "---------------------------------------------"
echo 
print_blue "     FontAwesomeFX Java 9 Jigsaw Modules"
echo 
print_blue "---------------------------------------------"
}

print_message() {
	printf '==> %s: \e[1m%s\e[m\n' "${1}" "${2}"
}

print_blue() {
	printf '\e[1;34m%s\e[m\n' "${1}"
}

print_green() {
	printf '\e[1;32m%s\e[m\n' "${1}"
}

print_red() {
	printf '\e[1;31m%s\e[m\n' "${1}"
}

print_bold() {
	printf '\e[1m%s\e[m\n' "${1}"
}

print_done() {
	printf '\e[1;32m\n==> Done.\e[m\n%s\n'
}

print_title() {
	printf '\n\n\e[1m==> %s\e[m\n\n' "${1}"
}

compile() {
  print_title "Compile"
  (rm -rf bin && mkdir bin) || exit

  modules=( "de.jensd.fx.glyphs.commons"
     "de.jensd.fx.glyphs.fontawesome"
     "de.jensd.fx.glyphs.icons525"
     "de.jensd.fx.glyphs.octicons"
     "de.jensd.fx.glyphs.weathericons"
     "de.jensd.fx.glyphs.materialicons"
     "de.jensd.fx.glyphs.materialdesignicons" )
  for MODULE_NAME in "${modules[@]}"
  do
    print_message "compiling" "$MODULE_NAME"
    mkdir bin/${MODULE_NAME}
    ${JAVA9_HOME}/bin/javac -modulepath bin -d bin/${MODULE_NAME} \
        $(find src/$MODULE_NAME -name "*.java") || exit
  done

  fonts=( "de.jensd.fx.glyphs.fontawesome/de/jensd/fx/glyphs/fontawesome/fontawesome-webfont.ttf"
    "de.jensd.fx.glyphs.icons525/de/jensd/fx/glyphs/icons525/525icons.ttf"
  	"de.jensd.fx.glyphs.octicons/de/jensd/fx/glyphs/octicons/octicons.ttf"
  	"de.jensd.fx.glyphs.weathericons/de/jensd/fx/glyphs/weathericons/weathericons-regular-webfont.ttf"
  	"de.jensd.fx.glyphs.materialicons/de/jensd/fx/glyphs/materialicons/MaterialIcons-Regular.ttf"
  	"de.jensd.fx.glyphs.materialdesignicons/de/jensd/fx/glyphs/materialdesignicons/materialdesignicons-webfont.ttf" )
  for font in "${fonts[@]}"
  do
  	src_dir="src/$font"
    bin_dir=bin/$(dirname "${font}")
  	print_message "copy" "$src_dir to $bin_dir"
    cp ${src_dir} ${bin_dir} || exit
  done

  find bin -type f
  print_done
}

assemble() {
  print_title "Assemble"
  (rm -rf lib && mkdir lib) || exit

  ${JAVA9_HOME}/bin/jar --create --file=lib/fontawesomefx-commons.jar \
      --module-version=1.0 \
      -C bin/de.jensd.fx.glyphs.commons . || exit
  ${JAVA9_HOME}/bin/jar --print-module-descriptor --file=lib/fontawesomefx-commons.jar || exit

  modules=( "fontawesome:FontAwesomeIconsDemoApp"
    "icons525:Icons525DemoApp"
    "octicons:OctIconsDemoApp"
    "weathericons:WeatherIconsDemoApp"
    "materialicons:MaterialIconsDemoApp"
    "materialdesignicons:MaterialDesignIconsDemoApp" )

  for MODULE in "${modules[@]}"
  do
     IFS=':' read -r -a MODULE_TUPLE <<< "$MODULE"
     ${JAVA9_HOME}/bin/jar --create --file=lib/fontawesomefx-${MODULE_TUPLE[0]}.jar \
          --module-version=1.0 \
          --main-class=de.jensd.fx.glyphs.${MODULE_TUPLE[0]}.demo.${MODULE_TUPLE[1]} \
          -C bin/de.jensd.fx.glyphs.${MODULE_TUPLE[0]} . || exit
      ${JAVA9_HOME}/bin/jar --print-module-descriptor --file=lib/fontawesomefx-${MODULE_TUPLE[0]}.jar || exit
  done
  print_done
}

link() {
  print_title "Link"
  (rm -rf ${APP_TITLE}) || exit

  ${JAVA9_HOME}/bin/jlink \
    --modulepath ${JAVA9_HOME}/jmods:lib \
    --addmods de.jensd.fx.glyphs.fontawesome \
    --addmods de.jensd.fx.glyphs.icons525 \
    --addmods de.jensd.fx.glyphs.octicons \
    --addmods de.jensd.fx.glyphs.weathericons \
    --addmods de.jensd.fx.glyphs.materialicons \
    --addmods de.jensd.fx.glyphs.materialdesignicons \
    --output ${APP_TITLE} \
    --exclude-files *.diz \
    --compress=2 \
    --strip-debug

    print_done
}

clean() {
  print_title "Clean"
  print_message "Removing directory" "bin"
  (rm -rf bin) || exit
  print_message "Removing directory" "lib"
  (rm -rf lib) || exit
  print_message "Removing directory" "${APP_TITLE}"
  (rm -rf ${APP_TITLE}) || exit
  print_done
}

help() {
  echo
  print_message "Usage:" "${0} [ compile | assemble | link | clean | help ]"
cat <<EOF

    compile  : compiles the source code
    assemble : creates all modules
    link     : linkes all modules and creates a demo app called "FontAwesomeFX-app"
    clean    : deletes directories: bin lib, FontAwesomeFX-app
    help     : display this help

EOF
}

print_header

case "${1}" in
  compile)   compile ;;
  assemble)  assemble ;;
  link)      link ;;
  clean)     clean ;;
  help)     help ;;
  *)        help ;;
esac
