#!/bin/bash

# This script will help you uninstall Enlightenment and related applications cleanly and safely.
# Note that the binary dependencies (dev packages) are preserved for system consistency.
# There is no safe way to remove them automatically, without close supervision by the user.

# --- Call the companion script ---
source "$HOME"/.eeminent/ekonfig.sh

# --- Enlightenment programs to be removed ---
prog_rm=(

)

# --- Clean up leftover files after uninstall ---
