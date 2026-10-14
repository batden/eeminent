#!/bin/bash
# shellcheck disable=SC1091 disable=SC2154 disable=SC2164

# EEMINENT.SH only supports Resolute Raccoon. It does not support other ubuntu releases or
# non-Ubuntu distributions. It handles downloading, configuring, and building everything
# necessary to enjoy the latest version of this unique environment.

# --- Call the companion scripts ---
source "$HOME"/.eeminent/ekonfig.sh

menu_slct() {
  is_einstl=$1

  echo
  if [ "$is_einstl" == false ]; then
    printf "1 $green_bright%s $off%s\n\n" "Install essentials only"
    printf "2 $orange_bright%s $off%s\n\n" "Install the whole ecosystem"
    printf "3 $blue_dim%s $off%s\n\n" "(Update and rebuild essentials only)"
    printf "4 $magenta_dim%s $off%s\n\n" "(Update essentials and build the whole ecosystem)"
    printf "5 $orange_dim%s $off%s\n\n" "(Update the whole ecosystem)"
    printf "6 $red_dim%s $off%s\n\n" "(Uninstall Enlightenment and related programs)"
    printf "7 $italic%s $off%s\n\n" "Quit the script"
  else
    printf "1 $green_dim%s $off%s\n\n" "(Install essentials only)"
    printf "2 $orange_dim%s $off%s\n\n" "(Install the whole ecosystem)"
    printf "3 $blue_bright%s $off%s\n\n" "Update and rebuild essentials only"
    printf "4 $magenta_bright%s $off%s\n\n" "Update essentials and build the whole ecosystem"
    printf "5 $orange_bright%s $off%s\n\n" "Update the whole ecosystem"
    printf "6 $red_bright%s $off%s\n\n" "Uninstall Enlightenment and related programs"
    printf "7 $italic%s $off%s\n\n" "Quit the script"
  fi

  read -r usr_input
}

# --- Binary dependencies check ---
bin_deps() {
  if ! sudo apt install "${deps[@]}"; then
    err_msg "CONFLICTING OR MISSING DEB PACKAGES OR DPKG DATABASE IS LOCKED."
    exit 1
  fi
}

# --- Source dependencies check ---
cnt_dir_min() {
  count=$(find . -mindepth 1 -maxdepth 1 -type d | wc -l)

  if [ ! -d efl ] || [ ! -d terminology ] || [ ! -d enlightenment ]; then
    err_msg "FAILED TO DOWNLOAD MAIN COMPONENT."
    exit 1
  fi
  # Tip: You can try downloading the missing file(s) manually (see the "Source repositories of
  # Enlightenment programs" section in EKONFIG.SH), then rerun the script and select option 1 again.
  # Alternatively, you can relaunch the script at a later time. In both cases, enter the same path
  # for the Enlightenment source folders as before.

  case $count in
  3)
    printf "$green_bright%s $off%s\n\n" "All programs have been downloaded successfully."
    sleep 2
    ;;
  0)
    err_msg "OOPS! SOMETHING WENT WRONG."
    exit 1
    ;;
  *)
    printf "\n$yellow_bright%s %s\n" "WARNING: ONLY $count OF 3 PROGRAMS HAVE BEEN DOWNLOADED!"
    printf "\n$yellow_bright%s $off%s\n\n" "WAIT 10 SECONDS OR HIT CTRL+C TO EXIT NOW."
    sleep 10
    ;;
  esac

  return 0
}

cnt_dir_max() {
  count=$(find . -mindepth 1 -maxdepth 1 -type d | wc -l)

  if [ ! -d efl ] || [ ! -d terminology ] || [ ! -d enlightenment ]; then
    err_msg "FAILED TO DOWNLOAD MAIN COMPONENT."
    exit 1
  fi

  case $count in
  15)
    printf "$green_bright%s $off%s\n\n" "All programs have been downloaded successfully."
    sleep 2
    ;;
  0)
    err_msg "OOPS! SOMETHING WENT WRONG."
    exit 1
    ;;
  *)
    printf "\n$yellow_bright%s %s\n" "WARNING: ONLY $count OF 15 PROGRAMS HAVE BEEN DOWNLOADED!"
    printf "\n$yellow_bright%s $off%s\n\n" "WAIT 10 SECONDS OR HIT CTRL+C TO EXIT NOW."
    sleep 10
    ;;
  esac

  return 0
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

# --- Ensure that Enlightenment system files are correctly installed ---
mv_sysfiles() {
  sudo mkdir -p /etc/enlightenment
  sudo mv -f /usr/local/etc/enlightenment/sysactions.conf /etc/enlightenment/sysactions.conf
  sudo mv -f /usr/local/etc/xdg/menus/e-applications.menu /etc/xdg/menus/e-applications.menu
}

build_essentials() {
  do_bsh_alias
  bin_deps
  set_p_src

  sudo ln -sf /usr/lib/x86_64-linux-gnu/preloadable_libintl.so /usr/lib/libintl.so
  sudo ldconfig

  cd "$(cat "$HOME/.cache/ebuilds/storepath")/enlighten"

  printf "\n\n$bold%s $off%s\n\n" "Fetching source code from the Enlightenment git repositories..."
  $clonefl
  $clonety
  $clonenl

  cnt_dir_min

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

rebuild_essentials() {
  bin_deps

  for i in "${prog_mbs_min[@]}"; do
    cd "$(cat "$HOME/.cache/ebuilds/storepath")/enlighten/$i"
    printf "\n$bold%s $off%s\n\n" "Rebuilding $i..."
    git reset --hard &>/dev/null
    $rebasef && git pull

    case $i in
    efl)
    meson setup --reconfigure build -Dbuildtype=release \
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
    meson setup --reconfigure build -Dbuildtype=release \
        -Dwl=true
      ninja -C build || mng_err
      ;;
    terminology)
    meson setup --reconfigure build -Dbuildtype=release
      ninja -C build || mng_err
      ;;
    esac

    $snin
    sudo ldconfig
  done
}

build_essentials_go() {
  clear
  printf "\n$green_bright%s $off%s\n\n" "* BUILDING ESSENTIAL ENLIGHTENMENT COMPONENTS *"

  build_essentials
  mv_sysfiles

  # This will protect the file from accidental deletion.
  sudo chattr +i "$HOME/.cache/ebuilds/storepath"

  echo
  cowsay "Now log out of your existing session, then select Enlightenment (Wayland) \
  on the login screen... That's All Folks!"

  cp -f "$dldir/eeminent.sh" "$HOME/.local/bin"

  exit 0
}

rebuild_essentials_go() {
  clear
  printf "\n$blue_bright%s $off%s\n\n" "* REBUILDING ESSENTIAL ENLIGHTENMENT COMPONENTS *"

  # Check for available updates of the script folder first.
  cd "$scrfldr" && git pull &>/dev/null
  cp -f eeminent.sh "$HOME/.local/bin"
  chmod +x "$HOME/.local/bin/eeminent.sh"
  sleep 1

  rebuild_essentials

  echo
  printf "$green_bright%s $off%s\n\n" "Essential components rebuilt successfully."

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
      build_essentials_go
      ;;
    2)
      source "$HOME"/.eeminent/embrace.sh
      do_tests
      build_all
      ;;
    3)
      do_test
      rebuild_essentials_go
      ;;
    4)
      source "$HOME"/.eeminent/embrace.sh
      do_test
      build_all_go
      ;;
    5)
      source "$HOME"/.eeminent/embrace.sh
      do_test
      rebuild_all_go
      ;;
    6)
      source "$HOME"/.eeminent/expel.sh
      uninstall_enlighten
      printf "\n\n$red_bright%s $off%s\n\n" "Done."
      break
      ;;
    7)
      printf "\n$bold%s $off%s\n\n" "Bye!"
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