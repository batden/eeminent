#!/bin/bash
#shellcheck  disable=SC1091 disable=SC2154 disable=SC2164

# EEMINENT.SH only supports Resolute Raccoon. It does not support other ubuntu releases or
# non-Ubuntu distributions. It handles downloading, configuring, and building everything
# necessary to enjoy the latest version of this unique environment.

# --- Call the companion script ---
source "$HOME"/.eeminent/ekonfig.sh

menu_slct() {
  is_einstl=$1

  echo
  if [ "$is_einstl" == false ]; then
    printf "1 $green_bright%s $off%s\n\n" "Install essentials only"
    printf "2 $orange_bright%s $off%s\n\n" "Install the whole ecosystem"
    printf "3 $magenta_dim%s $off%s\n\n" "(Update and rebuild essentials)"
    printf "4 $blue_dim%s $off%s\n\n" "(Update and rebuild the whole ecosystem)"
    printf "5 $red_dim%s $off%s\n\n" "(Uninstall Enlightenment and related programs)"
    printf "6 $italic%s $off%s\n\n" "Quit the script"
  else
    printf "1 $green_dim%s $off%s\n\n" "(Install essentials only)"
    printf "2 $orange_dim%s $off%s\n\n" "(Install the whole ecosystem)"
    printf "3 $magenta_bright%s $off%s\n\n" "Update and rebuild essentials"
    printf "4 $blue_bright%s $off%s\n\n" "Update and rebuild the whole ecosystem"
    printf "5 $red_bright%s $off%s\n\n" "Uninstall Enlightenment and related programs"
    printf "6 $italic%s $off%s\n\n" "Quit the script"
  fi

  read -r usr_input
}

# --- Binary dependencies check ---
bin_deps_min() {
  if ! sudo apt install "${deps_min[@]}"; then
    err_msg "CONFLICTING OR MISSING DEB PACKAGES OR DPKG DATABASE IS LOCKED."
    exit 1
  fi
}

# --- Set path for Enlightenment source folders ---
set_p_src() {
  echo

  # Do not append a trailing slash (/) to the end of the path prefix.
  read -r -p "Please enter a path for the Enlightenment source folders \
  (e.g. /home/$LOGNAME/Documents or /home/$LOGNAME/testing): " mypath

  if [[ ! "$mypath" =~ ^/home/$LOGNAME.* ]]; then
    err_msg "PATH MUST BE WITHIN YOUR HOME DIRECTORY (/home/$LOGNAME)"
    exit 1
  fi

  echo
  read -r -p "Create directory $mypath/sources? [Y/n] " confirm

  if [[ $confirm =~ ^[Nn]$ ]]; then
    exit 1
  fi

  mkdir -p "$mypath/sources"
  p_srcdir="$mypath/sources"
  echo "$p_srcdir" >"$HOME/.cache/ebuilds/storepath"
  printf "\n$green_bright%s $off%s\n\n" "You have chosen: $p_srcdir"
  sleep 2

  cd "$HOME"
  esrcdir="$p_srcdir"
  mkdir -p "$esrcdir/enlighten"
  cd "$esrcdir/enlighten"
}

build_essentials() {
  clear
  printf "\n$green_bright%s $off%s\n\n" "* BUILDING ESSENTIAL ENLIGHTENMENT COMPONENTS *"
  do_bash_alias
  bin_deps_min
  set_p_src

  sudo ln -sf /usr/lib/x86_64-linux-gnu/preloadable_libintl.so /usr/lib/libintl.so
  sudo ldconfig

  cd "$(cat "$HOME/.cache/ebuilds/storepath")/enlighten"

  printf "\n\n$bold%s $off%s\n\n" "Fetching source code from the Enlightenment git repositories..."
  $clonefl
  $clonety
  $clonenl

  for i in "${prog_mbs_min[@]}"; do
    cd "$(cat "$HOME/.cache/ebuilds/storepath")/enlighten/$i"
    printf "\n$bold%s $off%s\n\n" "Building $i..."

    case $i in
    efl)
      meson setup build -Dbuildtype=release \
        -Dnative-arch-optimization=true \
        -Dfb=true \
        -Dharfbuzz=true \
        -Dlua-interpreter=lua \
        -Delua=true \
        -Dbindings=lua,cxx \
        -Devas-loaders-disabler= \
        -Dglib=true \
        -Ddrm=true \
        -Dwl=true \
        -Dopengl=es-egl \
        -Dbuild-tests=false \
        -Ddocs=false \
        -Dpipewire=true
      ninja -C build || mng_err
      ;;
    enlightenment)
      meson setup build -Dbuildtype=release \
        -Dwl=true
      ninja -C build || mng_err
      ;;
    terminology)
      meson setup build -Dbuildtype=release
      ninja -C build
      ;;
    esac

    $snin
    sudo ldconfig
  done
}

essentials_go() {
  clear
  printf "\n$orange_bright%s $off%s\n\n" "* BUILDING ESSENTIAL ENLIGHTENMENT COMPONENTS *"

  build_essentials

  sudo mkdir -p /usr/share/wayland-sessions
  sudo mv -f /usr/local/share/wayland-sessions/enlightenment-wayland.desktop \
    /usr/share/wayland-sessions/enlightenment-wayland.desktop &>/dev/null

  if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    echo
    cowsay -f www "Now log out of your existing session and press Ctrl+Alt+F3 to switch to tty3, \
        then enter your credentials and type: enlightenment_start" | lolcat -a
    echo
    # Wait a few seconds for the Wayland session to start.
    # When you're done, type exit
    # Pressing Ctrl+Alt+F1 will bring you back to the login screen.
  else
    echo
    cowsay -f www "That's it. Now type: enlightenment_start"
    echo
    # If Enlightenment fails to start, relaunch the script and select option ???
    # After the build is complete, type exit, then go back to the login screen.
  fi

  exit 0
}

# --- First, display the selection menu... ---
lo() {
  trap 'handle_sig 130' SIGINT

  usr_input=0
  printf "\n$bold%s $off%s\n" "Please enter the number of your choice:"

  if [ ! -x /usr/local/bin/enlightenment_start ]; then
    menu_slct false
  else
    menu_slct true
  fi
}

# --- Then get the user's choice ---
and_behold() {
  while true; do
    case "$usr_input" in
    1)
      do_tests
      build_essentials
      ;;
    2)
      do_tests
      build_all
      ;;
    3)
      do_test
      rebuild_essentials
      ;;
    4)
      do_test
      rebuild_all
      ;;
    5)
      source "$HOME"/.eeminent/expel.sh
      uninstall_enlighten
      printf "\n\n$red_bright%s $off%s\n\n" "Done."
      break
      ;;
    6)
      printf "\n$blue_bright%s $off%s\n\n" "Bye!"
      exit 0
      ;;
    *)
      printf "\n$red_bright%s $off%s\n\n" "INVALID INPUT."
      exit 1

      ;;
    esac
  done

  return 0
}

# --- Main entry point ---
main() {
  lo
  and_behold
}

main "$@"