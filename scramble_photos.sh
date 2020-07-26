#!/usr/bin/env sh
#
# Description: Removes exif data from all photos in the current directory.
#
# Homepage: https://git.sr.ht/~krathalan/miscellaneous-scripts
#
# Copyright (C) 2020 krathalan
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# -----------------------------------------
# -------------- Guidelines ---------------
# -----------------------------------------

# This script follows the Google Shell Style Guide:
# https://google.github.io/styleguide/shell.xml

# This script uses shellcheck: https://www.shellcheck.net/

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -eu # (Eo pipefail) is Bash only!

# This script spawns subshell processes
trap 'killall background' INT

# -----------------------------------------
# ----------- Program variables -----------
# -----------------------------------------

# Colors
readonly RED=$(tput bold && tput setaf 1)
readonly NC=$(tput sgr0) # No color/turn off all tput attributes

# Other
readonly SCRIPT_NAME=$(basename "$0")
readonly TARGET_DIRECTORY="${HOME}/pictures/$(date +%Y)"

# -----------------------------------------
# ------------- User variables ------------
# -----------------------------------------

toCopy="true"

# -----------------------------------------
# --------------- Functions ---------------
# -----------------------------------------

#######################################
# Prints passed error message before premature exit.
# Prints everything to >&2 (STDERR).
# Globals:
#   RED, NC
#   SCRIPT_NAME
# Arguments:
#   $1: error message to print
# Returns:
#   none
#######################################
exit_script_on_failure()
{
  printf "%sError%s: %s\n" "${RED}" "${NC}" "$1" >&2
  printf "Exiting %s Bash script.\n" "${SCRIPT_NAME}" >&2

  exit 1
}

#######################################
# Removes all exif data from a photo.
# Globals:
#   none
# Arguments:
#   $1: photo to remove exif data from
# Returns:
#   none
#######################################
scramble_it()
{
  readonly photo="$1"

  # Scramble!
  exiftool -q -all= "${photo}"

  # Restore date taken
  exiftool -q "-datetimeoriginal<filename" "${photo}"

  # Delete original
  rm -f "${photo}_original"

  # Move to appropriate folder
  if [ "${toCopy}" = "true" ]; then
    mv "${photo}" "${TARGET_DIRECTORY}"
  fi

  printf "%s scrambled\n" "${photo##*/}"
}

# -----------------------------------------
# ---------------- Script -----------------
# -----------------------------------------

if [ "$(whoami)" = "root" ]; then
  exit_script_on_failure "This script should NOT be run as root (or sudo)!"
fi

# Check for exiftool binary
if [ -z "$(command -v exiftool)" ]; then
  exit_script_on_failure "Exiftool binary not found."
fi

if [ $# -gt 0 ] && [ "$1" = "--no-copy" ]; then
  toCopy="false"
else
  if [ ! -d "${TARGET_DIRECTORY}" ]; then
    mkdir -p "${TARGET_DIRECTORY}"
  fi
fi

for photo in "${PWD}"/*; do
  case "${photo}" in
    *.png|*.jpg|*.jpeg)
      scramble_it "${photo}" &
      ;;
    *)
      printf "%s is not a photo, skipping\n" "${photo##*/}"
  esac
done

wait
