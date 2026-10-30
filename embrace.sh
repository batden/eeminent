#!/bin/bash
# shellcheck disable=SC1091 disable=SC2154 disable=SC2164

# This script contains functions used by the other scripts.

# EMBRACE.SH is licensed under a Creative Commons Attribution 4.0 International License,
# in memory of Aaron Swartz.
# See https://creativecommons.org/licenses/by/4.0/

# --- Call the companion script ---
source "$HOME"/.eeminent/ekonfig.sh

build_all() {
  clear
  printf "\n\n$orange_bright%s $off%s\n\n" "* BUILDING THE FULL ENLIGHTENMENT ECOSYSTEM *"
  do_bsh_alias
  bin_deps
  set_p_src

  cd "$(cat "$HOME/.cache/ebuilds/storepath")/enlighten"

  printf "\n\n$bold%s $off%s\n\n" "Fetching source code from the Enlightenment git repositories..."
  $clonefl
  echo
  $clonety
  echo
  $clonenl
  echo
  $cloneph
  echo
  $clonerg
  echo
  $clonevi
  echo
  $clonexp
  echo
  $clonecr
  echo
  $cloneve
  echo
  $clonedi
  echo
  $clonent
  echo
  $cloneft
  echo
  $clonepn
  echo
  $clonepl

  printf "\n\n$bold%s $off%s\n\n" "Fetching source code from Dimmus' git repository..."
  $clonete
  echo

  cnt_dir_max

  sudo ln -sf /usr/lib/x86_64-linux-gnu/preloadable_libintl.so /usr/lib/libintl.so
  sudo ldconfig

  for i in "${prog_mbs_full[@]}"; do
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
        ninja -C build || mng_err
        ;;
      edi)
        meson setup build -Dbuildtype=release -Dlibclang=false
        ninja -C build
        ;;
      *)
        meson setup build -Dbuildtype=release
        ninja -C build
        ;;
    esac

    $snin
    sudo ldconfig
  done
}

build_alt() {
  clear
  printf "\n$magenta_bright%s $off%s\n\n" "* BUILDING THE OTHER COMPONENTS *"
  bin_deps

  cd "$(cat "$HOME/.cache/ebuilds/storepath")/enlighten"

  printf "\n\n$bold%s $off%s\n\n" "Fetching source code from the Enlightenment git repositories..."
  $cloneph
  echo
  $clonerg
  echo
  $clonevi
  echo
  $clonexp
  echo
  $clonecr
  echo
  $cloneve
  echo
  $clonedi
  echo
  $clonent
  echo
  $cloneft
  echo
  $clonepn
  echo
  $clonepl

  printf "\n\n$bold%s $off%s\n\n" "Fetching source code from Dimmus' git repository..."
  $clonete
  echo

  cnt_dir_alt

  for i in "${prog_mbs_alt[@]}"; do
    cd "$(cat "$HOME/.cache/ebuilds/storepath")/enlighten/$i"
    printf "\n$bold%s $off%s\n\n" "Building $i..."

    case $i in
      edi)
        meson setup build -Dbuildtype=release -Dlibclang=false
        ninja -C build
        ;;
      *)
        meson setup build -Dbuildtype=release
        ninja -C build
        ;;
    esac

    $snin
    sudo ldconfig
  done
}

build_all_go() {
  if pkg-config --exists efl \
      && command -v terminology >/dev/null \
      && command -v enlightenment >/dev/null; then
    build_alt
  else
    build_all
    mv_sysfiles
  fi

  # This will protect the file from accidental deletion.
  sudo chattr +i "$HOME/.cache/ebuilds/storepath"

  # Note: Enlightenment adds three shortcut icons (namely home.desktop, root.desktop and tmp.desktop)
  # to your Desktop folder. You can safely delete them if it bothers you.

  echo
  cowsay "Now log out of your existing session, then select Enlightenment (Wayland) \
    on the login screen... That's All Folks!"
  echo

  cp -f "$dldir/eeminent.sh" "$HOME/.local/bin"

  exit 0
}

rebuild_all_go() {
  clear
  printf "\n\n$orange_bright%s $off%s\n\n" "* REBUILDING THE FULL ENLIGHTENMENT ECOSYSTEM *"

  if [ "$XDG_CURRENT_DESKTOP" == "Enlightenment" ]; then
    printf "\n$red_bright%s $off%s\n\n" \
      "Please log in to your default desktop to do this."
    exit 1
  fi

  bin_deps

  for i in "${prog_mbs_full[@]}"; do
    cd "$(cat "$HOME/.cache/ebuilds/storepath")/enlighten/$i"
    printf "\n$bold%s $off%s\n\n" "Rebuilding $i..."

    case $i in
      efl)
        sudo chown "$USER" build/.ninja*
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
        sudo chown "$USER" build/.ninja*
        meson setup --reconfigure build -Dbuildtype=release \
          -Dwl=true
        ninja -C build || mng_err
        ;;
      terminology)
        sudo chown "$USER" build/.ninja*
        meson setup --reconfigure build -Dbuildtype=release
        ninja -C build || mng_err
        ;;
      edi)
        sudo chown "$USER" build/.ninja*
        meson setup --reconfigure build -Dbuildtype=release -Dlibclang=false
        ninja -C build
        ;;
      *)
        sudo chown "$USER" build/.ninja*
        meson setup --reconfigure build -Dbuildtype=release
        ninja -C build
        ;;
    esac

    $snin
    sudo ldconfig
  done

  rm_sysfiles

  printf "\n$green_bright%s $off%s\n\n" "Enlightenment components rebuilt successfully."

  exit 0
}