#!/bin/bash
# shellcheck disable=SC1091 disable=SC2034 disable=SC2154

# This script contains variables, functions, and tests used by the other scripts.

# EKONFIG.SH is licensed under a Creative Commons Attribution 4.0 International License,
# in memory of Aaron Swartz.
# See https://creativecommons.org/licenses/by/4.0/


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

deps=(
build-essential
ccache
check
cmake
cowsay
doxygen
gettext
gperf
graphviz
gstreamer1.0-plugins-bad
gstreamer1.0-plugins-ugly
i2c-tools
libasound2-dev
libavahi-client-dev
libavif-dev
libbluetooth-dev
libbz2-dev
libblkid-dev
libconfig-dev
libddcutil-dev
libexif-dev
libfontconfig-dev
libfribidi-dev
libfreetype-dev
libgeoclue-2-dev
libgif-dev
libgles-dev
libgraphviz-dev
libgstreamer-plugins-base1.0-dev
libgstreamer1.0-dev
libharfbuzz-dev
libheif-dev
libi2c-dev
libibus-1.0-dev
libinput-dev
libinput-tools
libjpeg-dev
libjson-c-dev
libjxl-dev
liblua5.2-dev
liblz4-dev
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
libspectre-dev
libssl-dev
libtiff-dev
libudev-dev
libudisks2-dev
libunibreak-dev
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
lxmenu-data
libxrandr-dev
libxss-dev
libxtst-dev
meson
ninja-build
systemd-dev
texlive-base
texlive-font-utils
valgrind
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

prog_mbs_alt=(
  ephoto
  rage
  evisum
  express
  ecrire
  enventor
  edi
  entice
  enlightenment-module-forecasts
  enlightenment-module-penguins
  enlightenment-module-places
  eflete
)

prog_mbs_full=(
  efl
  terminology
  enlightenment
  ephoto
  rage
  evisum
  express
  ecrire
  enventor
  edi
  entice
  enlightenment-module-forecasts
  enlightenment-module-penguins
  enlightenment-module-places
  eflete
)

# --- System checks ---
do_tests() {
  printf "\n\n$bold%s $off%s\n" "System checks..."

  if [[ "$distro" == "resolute" ]]; then
    printf "\n$green_bright%s $off%s\n\n" "Ubuntu ${distro^}... OK"
    sleep 1
  else
    printf "\n$red_bright%s $off%s\n\n" "Unsupported operating system [ $(lsb_release -ds) ]."
    exit 1
  fi

  if ! git ls-remote https://git.enlightenment.org/enlightenment/efl.git HEAD &>/dev/null; then
    printf "\n$red_bright%s %s\n" "Remote host is unreachable——try again later"
    printf "$red_bright%s $off%s\n\n" "or check your internet connection."
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

  source "$HOME/.bash_aliases"
}