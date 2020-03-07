#!/bin/sh
#
# Description: Takes a nice screenshot.
#
# Homepage: https://git.sr.ht/~krathalan/miscellaneous-scripts
#
# Copyright (C) 2019 krathalan
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

# -----------------------------------------
# ----------- Program variables -----------
# -----------------------------------------

# Colors
readonly RED=$(tput bold && tput setaf 1)
readonly NC=$(tput sgr0) # No color/turn off all tput attributes

# Other
readonly SCRIPT_NAME="$(basename "$0")"

# Determine pictures directory
USER_PICTURES_DIR="${HOME}/pictures"

if [ "$(command -v xdg-user-dir)" ]; then
  USER_PICTURES_DIR="$(xdg-user-dir PICTURES)"
fi

readonly SCREENSHOTS_DIR="${USER_PICTURES_DIR}/screenshots"

# -----------------------------------------
# ------------- User variables ------------
# -----------------------------------------

# -----------------------------------------
# --------------- Functions ---------------
# -----------------------------------------

#######################################
# Checks to see if a specified command is available and exits the script if the command is not available.
# Globals:
#   none
# Arguments:
#   $1: command to test
# Returns:
#   none
#######################################
check_command()
{
  if [ ! -x "$(command -v "$1")" ]; then
    exit_script_on_failure "Package $1 is required and is not installed."
  fi
}

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
  
  notify-send -i "script-error" "${SCRIPT_NAME}" "Error: $1"

  exit 1
}

# -----------------------------------------
# ---------------- Script -----------------
# -----------------------------------------

if [ "$(whoami)" = "root" ]; then
  exit_script_on_failure "This script should NOT be run as root (or sudo)!"
fi

# Make screenshots directory if it does not exist yet
mkdir -p "${SCREENSHOTS_DIR}"

notificationMessage="Saved screenshot to ${SCREENSHOTS_DIR}."

# Convert output file name to lowercase for easier tab completion
outputFile="${SCREENSHOTS_DIR}/$(printf "%s" "screen-$(date +%b-%d-%Y-%H-%M-%S).jpg" | tr '[:upper:]' '[:lower:]')"

if [ ! "${SWAYSOCK:-x}" = "x" ]; then
  check_command "grim"

  if [ $# -gt 0 ]; then
    if [ -x "$(command -v "slurp")" ]; then
      grim -g "$(slurp)" -t jpeg -q 95 "${outputFile}"

      if [ -x "$(command -v "wl-copy")" ]; then
        wl-copy < "${outputFile}"
        rm -f "${outputFile}"
        notificationMessage="Copied selection to clipboard."
      fi
    fi
  else
    grim -t jpeg -q 95 "${outputFile}"
  fi
else
  check_command "scrot"
  scrot -q 95 "${outputFile}"
fi

notify-send -i "folder-pictures-open" "${SCRIPT_NAME}" "${notificationMessage}"

printf "Done.\n"
