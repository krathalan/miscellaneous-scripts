#!/usr/bin/env sh
#
# Description: Plays a sound on a loop when the timer goes off.
#
# Homepage: https://git.sr.ht/~krathalan/miscellaneous-scripts
#
# Copyright (C) 2020 Hunter Peavey
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
  exit 1
}

# -----------------------------------------
# ---------------- Script -----------------
# -----------------------------------------

[ "$(whoami)" = "root" ] &&
  exit_script_on_failure "This script should NOT be run as root (or sudo)!"

[ -z "${1:-}" ] &&
  exit_script_on_failure "Missing argument: time (e.g. 5m)"

[ -z "${TIMER_SOUND_FILE:-}" ] && 
  exit_script_on_failure "Please set the environment variable TIMER_SOUND_FILE"

[ ! -f "${TIMER_SOUND_FILE}" ] &&
  exit_script_on_failure "TIMER_SOUND_FILE ${TIMER_SOUND_FILE} does not exist"

termdown "$1"

printf "\nPress <q> to stop..."
mpv --audio-display=no --really-quiet --loop=inf "${TIMER_SOUND_FILE}"

printf "\n"
