#!/bin/bash
# shellcheck disable=SC1091 disable=SC2154 disable=SC2164

# This script contains functions used by the other scripts.

# Optional: Additional steps may be taken to achieve optimal results.
# Please refer to the comments of the build_all() function.

# --- Call the companion script ---
source "$HOME"/.eeminent/ekonfig.sh

build_all() {
  # Fetch edi's additional dependencies before executing the script?
  # If you need libclang support in edi, you will also need to install
  # the packages listed in the link below:
  # https://gist.github.com/batden/99a7ebdd5ba9d9e83b2446ab5f05f3dc

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
        ninja -C build
        ;;
      edi)
        if [ ! -d "/usr/lib/llvm-11" ]; then
          printf "\n$yellow_bright%s %s\n" "WARNING: LLVM-11 DEPENDENCIES WERE NOT FOUND."
          printf "\n$yellow_bright%s $off%s\n\n" "BUILDING EDI WITHOUT LIBCLANG SUPPORT."
          sleep 1
          meson setup build -Dbuildtype=release -Dlibclang=false
          ninja -C build
        else
          meson setup build -Dbuildtype=release \
            -Dlibclang=true \
            -Dlibclang-headerdir=/usr/lib/llvm-11/include \
            -Dlibclang-libdir=/usr/lib/llvm-11/lib
          ninja -C build
        fi
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
printf "\n\n$magenta_bright%s $off%s\n\n" "* BUILDING THE OTHER COMPONENTS *"

# --- Source repositories of Enlightenment programs ---
cloneph="git clone https://git.enlightenment.org/enlightenment/ephoto.git"
clonerg="git clone https://git.enlightenment.org/enlightenment/rage.git"
clonevi="git clone https://git.enlightenment.org/enlightenment/evisum.git"
clonexp="git clone https://git.enlightenment.org/enlightenment/express.git"
clonecr="git clone https://git.enlightenment.org/enlightenment/ecrire.git"
cloneve="git clone https://git.enlightenment.org/enlightenment/enventor.git"
clonedi="git clone https://git.enlightenment.org/enlightenment/edi.git"
clonent="git clone https://git.enlightenment.org/vtorri/entice.git"
cloneft="git clone https://git.enlightenment.org/enlightenment/enlightenment-module-forecasts.git"
clonepn="git clone https://git.enlightenment.org/enlightenment/enlightenment-module-penguins.git"
clonepl="git clone https://git.enlightenment.org/enlightenment/enlightenment-module-places.git"
clonete="git clone https://github.com/dimmus/eflete.git"

  for i in "${prog_mbs_alt[@]}"; do
    cd "$(cat "$HOME/.cache/ebuilds/storepath")/enlighten/$i"
    printf "\n$bold%s $off%s\n\n" "Building $i..."

    case $i in
      edi)
        if [ ! -d "/usr/lib/llvm-11" ]; then
          printf "\n$yellow_bright%s %s\n" "WARNING: LLVM-11 DEPENDENCIES WERE NOT FOUND."
          printf "\n$yellow_bright%s $off%s\n\n" "BUILDING EDI WITHOUT LIBCLANG SUPPORT."
          sleep 1
          meson setup build -Dbuildtype=release -Dlibclang=false
          ninja -C build
        else
          meson setup build -Dbuildtype=release \
            -Dlibclang=true \
            -Dlibclang-headerdir=/usr/lib/llvm-11/include \
            -Dlibclang-libdir=/usr/lib/llvm-11/lib
          ninja -C build
        fi
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
    rebuild_essentials_go
    build_alt
  else
    build_all
    mv_sysfiles
  fi

  # This will protect the file from accidental deletion.
  sudo chattr +i "$HOME/.cache/ebuilds/storepath"

  # Note: Enlightenment adds three shortcut icons (namely home.desktop, root.desktop and tmp.desktop)
  # to your Gnome Desktop; you can safely delete them if they bother you.

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
        ninja -C build
        ;;
      edi)
        sudo chown "$USER" build/.ninja*

        if [ ! -d "/usr/lib/llvm-11" ]; then
          sleep 1
          meson setup --reconfigure build -Dbuildtype=release -Dlibclang=false
          ninja -C build
        else
          meson setup --reconfigure build -Dbuildtype=release \
            -Dlibclang=true \
            -Dlibclang-headerdir=/usr/lib/llvm-11/include \
            -Dlibclang-libdir=/usr/lib/llvm-11/lib
          ninja -C build
        fi
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

  echo
  printf "$green_bright%s $off%s\n\n" "Enlightenment components rebuilt successfully."

  exit 0
}