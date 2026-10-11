#!/bin/bash

# EEMINENT.SH only supports Resolute Raccoon. It does not support other ubuntu releases or
# non-Ubuntu distributions. It handles downloading, configuring, and building everything
# necessary to enjoy the latest version of this unique environment

# --- Call the companion script ---
source "$HOME"/.eeminent/ekonfig.sh

menu_slct() {
  is_einstl=$1

  echo
  if [ "$is_einstl" == false ]; then
    printf "1 $green_bright%s $off%s\n\n" "Install essentials" | pv -qL 20
    printf "2 $orange_dim%s $off%s\n\n" "(Build the whole ecosystem)" | pv -qL 30
    printf "3 $red_dim%s $off%s\n\n" "(Uninstall Enlightenment and related programs)" | pv -qL 30
    printf "4 $italic%s $off%s\n\n" "Quit the script" | pv -qL 20
  else
    printf "1 $green_dim%s $off%s\n\n" "(Install essentials)" | pv -qL 30
    printf "2 $orange_bright%s $off%s\n\n" "Build the whole ecosystem" | pv -qL 20
    printf "3 $red_bright%s $off%s\n\n" "UNINSTALL the Enlightenment ecosystem" | pv -qL 20
    printf "4 $italic%s $off%s\n\n" "Quit the script" | pv -qL 20
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

# --- Programs to be built using the Meson build system ---
prog_mbs_min=(
  efl
  terminology
  enlightenment
)

build_essentials() {
  cd "$(cat "$HOME/.cache/ebuilds/storepath")/enlighten"

  printf "\n\n$bold%s $off%s\n\n" "Fetching source code from the Enlightenment git repositories..."
  $clonefl
  echo
  $clonety
  echo
  $clonenl
  echo

  do_bash_alias
  bin_deps_min
  set_p_src

  for i in "${prog_mbs_min[@]}"; do
    cd "$(cat "$HOME/.cache/ebuilds/storepath")/enlighten/$i"
    printf "\n$bold%s $off%s\n\n" "Updating $i..."
    git reset --hard &>/dev/null
    $rebasef && git pull

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
    *)
      meson setup build -Dbuildtype=release
      ninja -C build
      ;;
    esac

    beep_attention
    $snin
    sudo ldconfig
  done
}

# --- Set path for Enlightenment source folders ---
set_p_src() {
  echo

  # Do not append a trailing slash (/) to the end of the path prefix.
  read -r -p "Please enter a path for the Enlightenment source folders \
  (e.g. /home/$LOGNAME/Documents or /home/$LOGNAME/testing): " mypath

  if [[ ! "$mypath" =~ ^/home/$LOGNAME.* ]]; then
    err_msg "PATH MUST BE WITHIN YOUR HOME DIRECTORY (/home/$LOGNAME)"
    beep_exit
    exit 1
  fi

  echo
  read -r -p "Create directory $mypath/sources? [Y/n] " confirm

  if [[ $confirm =~ ^[Nn]$ ]]; then
    beep_exit
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

essentials_go() {
  clear
  printf "\n$orange_bright%s $off%s\n\n" "* BUILDING ESSENTIAL ENLIGHTENMENT COMPONENTS *"

  # Check for available updates of the script folder first.
  cd "$scrfldr" && git pull &>/dev/null
  cp -f eeminent.sh "$HOME/.local/bin"
  chmod +x "$HOME/.local/bin/eeminent.sh"
  sleep 1

  build_essentials

  sudo mkdir -p /usr/share/wayland-sessions
  sudo mv -f /usr/local/share/wayland-sessions/enlightenment-wayland.desktop \
    /usr/share/wayland-sessions/enlightenment-wayland.desktop &>/dev/null

  beep_ok

  if [ "$XDG_SESSION_TYPE" == "x11" ] || [ "$XDG_SESSION_TYPE" == "wayland" ]; then
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
    # If Enlightenment fails to start, relaunch the script and select option 2.
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
      source "$HOME"/.eeminent/expel.sh
      uninstall_enlighten
      printf "\n\n$red_bright%s $off%s\n\n" "Done."
      break
      ;;
    4)
      printf "\n$blue_bright%s $off%s\n\n" "Bye!"
      exit 0
      ;;
    *)
      printf "\n$red_bright%s $off%s\n\n" "INVALID INPUT."
      beep_exit
      exit 1

      ;;
    esac
  done

  return 0
}

# --- Main entry point ---
main() {
  chk_pv
  chk_sl
  chk_mn
  lo
  and_behold
}

main "$@"