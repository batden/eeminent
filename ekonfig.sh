#!/bin/bash
# shellcheck disable=SC1091 disable=SC2034 disable=SC2154

# This script contains variables, functions, and tests used by the other scripts.

# --- Color and formatting ---
green_bright="\e[1;38;5;118m"
magenta_bright="\e[1;38;5;201m"
orange_bright="\e[1;38;5;208m"
yellow_bright="\e[1;38;5;226m"
blue_bright="\e[1;38;5;74m"
red_bright="\e[1;38;5;1m"
green_dim="\e[2;38;5;118m"
magenta_dim="\e[2;38;5;201m"
orange_dim="\e[2;38;5;208m"
blue_dim="\e[2;38;5;74m"
red_dim="\e[2;38;5;1m"
bold="\e[1m"
italic="\e[3m"
off="\e[0m"

# --- Paths and aliases ---
dldir=$(xdg-user-dir DOWNLOAD)
#docdir=$(xdg-user-dir DOCUMENTS)
scrfldr=$HOME/.eeminent
rebasef="git config pull.rebase false"
snin="sudo ninja -C build install"
distro=$(lsb_release -sc)

# --- Manage errors and keyboard interrupts ---
trap 'mng_err' EXIT
trap 'handle_sig 130' SIGINT
trap 'handle_sig 143' SIGTERM

mng_err() {
  local exit_code=$?

  trap - EXIT

  if [ "$exit_code" -ne 0 ]; then
    err_msg "SCRIPT EXITED WITH ERROR" "$exit_code"
  fi

  exit "$exit_code"
}

handle_sig() {
   local exit_code=$1

  trap - SIGINT SIGTERM EXIT
  err_msg "KEYBOARD INTERRUPT" "$exit_code"
  exit "$exit_code"
}

err_msg() {
  local message=$1
  local code=${2:-}

  if [ -n "$code" ]; then
    printf "\n%b%s (CODE: %s)%b\n\n" \
      "$red_bright" "$message" "$code" "$off"
  else
    printf "\n%b%s%b\n\n" \
      "$red_bright" "$message" "$off"
  fi
}

deps_min=(
build-essential
ccache
check
cmake
cowsay
doxygen
libasound2-dev
libavif-dev
libbz2-dev
libconfig-dev
libexif-dev
libfontconfig-dev
libfribidi-dev
libfreetype-dev
libgif-dev
libgles-dev
libgstreamer-plugins-base1.0-dev
libgstreamer1.0-dev
libharfbuzz-dev
libheif-dev
libibus-1.0-dev
libinput-dev
libjpeg-dev
libjxl-dev
liblua5.2-dev
libopenjp2-7-dev
libosmesa6-dev
libpam0g-dev
libpipewire-0.3-dev
libpng-dev
libpoppler-cpp-dev
libpoppler-dev
libpulse-dev
libraw-dev
librlottie-dev
librsvg2-dev
libscim-dev
libsndfile1-dev
libssl-dev
libtiff-dev
libudev-dev
libunwind-dev
libwebp-dev
libx11-dev
libx11-xcb-dev
libxcomposite-dev
libxcursor-dev
libxdamage-dev
libxinerama-dev
libxkbcommon-dev
libxkbcommon-x11-dev
libxrandr-dev
libxss-dev
libxtst-dev
meson
ninja-build
systemd-dev
zlib1g-dev
)

# --- Source repositories of Enlightenment programs ---
clonefl="git clone https://git.enlightenment.org/enlightenment/efl.git"
clonety="git clone https://git.enlightenment.org/enlightenment/terminology.git"
clonenl="git clone https://git.enlightenment.org/enlightenment/enlightenment.git"
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

# --- Programs to be built using the Meson build system ---
prog_mbs_min=(
  efl
  terminology
  enlightenment
)

# --- System checks ---
do_tests() {

  printf "\n\n$bold%s $off%s\n" "System checks..."

  if systemd-detect-virt -q --container; then
    printf "\n$red_bright%s $off%s\n\n" "EEMINENT IS NOT INTENDED FOR USE INSIDE CONTAINERS."
    exit 1
  fi

  if [ "$distro" == resolute ]; then
    printf "\n$green_bright%s $off%s\n\n" "Ubuntu ${distro^}... OK"
    sleep 1
  else
    printf "\n$red_bright%s $off%s\n\n" "UNSUPPORTED OPERATING SYSTEM [ $(lsb_release -ds) ]."
    exit 1
  fi

  if ! git ls-remote https://git.enlightenment.org/enlightenment/efl.git HEAD &>/dev/null; then
    printf "\n$red_bright%s %s\n" "REMOTE HOST IS UNREACHABLE——TRY AGAIN LATER"
    printf "$red_bright%s $off%s\n\n" "OR CHECK YOUR INTERNET CONNECTION."
    exit 1
  fi

  if [[ ! -d "$HOME/.local/bin" ]]; then
    mkdir -p "$HOME/.local/bin"
  fi

  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
  esac

  if [[ ! -d "$HOME/.cache/ebuilds" ]]; then
    mkdir -p "$HOME/.cache/ebuilds"
  fi
}

# --- Create bash_aliases file ---
do_bsh_alias() {
  if [ -f "$HOME/.bash_aliases" ]; then
    mv -vb "$HOME/.bash_aliases" "$HOME/.bash_aliases_bak"
    echo
    touch "$HOME/.bash_aliases"
  else
    touch "$HOME/.bash_aliases"
  fi

  cat >"$HOME/.bash_aliases" <<EOF
    # Compiler and linker flags added by EKONFIG.SH
    export CC="ccache gcc"
    export CXX="ccache g++"
    export USE_CCACHE=1
    export CCACHE_COMPRESS=6
    export CPPFLAGS=-I/usr/local/include
    export LDFLAGS=-L/usr/local/lib
    export PKG_CONFIG_PATH=/usr/local/lib/x86_64-linux-gnu/pkgconfig:/usr/local/lib/pkgconfig

    # Keyring service workaround for Enlightenment.
    # You also need to autostart some additional services at startup for this to work:
    # See the repository's wiki (Startup Applications) for more info.
    #
    if printenv | grep -q 'XDG_CURRENT_DESKTOP=Enlightenment'; then
      export SSH_AUTH_SOCK=/run/user/${UID}/keyring/ssh
    fi
EOF

  . "$HOME/.bash_aliases"
}