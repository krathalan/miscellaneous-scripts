#!/usr/bin/env sh
#
# Description: Makes a looping .gif from a set of images.
#
# Homepage: https://git.sr.ht/~krathalan/miscellaneous-scripts
#
# Copyright (C) 2019-2020 krathalan
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

readonly SCRIPT_NAME="${0##*/}"
readonly TEMP_DIRECTORY="/tmp/.make_gif"
readonly WORKING_DIRECTORY="${PWD}"

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
  printf "\n%sError%s: %s\n" "${RED}" "${NC}" "$1" >&2
  printf "Exiting %s Bash script.\n" "${SCRIPT_NAME}" >&2

  exit 1
}

# -----------------------------------------
# ---------------- Script -----------------
# -----------------------------------------

if [ "$(whoami)" = "root" ]; then
  exit_script_on_failure "This script should NOT be run as root (or sudo)!"
fi

rm -rf "${TEMP_DIRECTORY}"
mkdir "${TEMP_DIRECTORY}"

printf "\nResizing images..."

for image in ./*.png; do
  convert "${image}" -resize 13% "${TEMP_DIRECTORY}/${image}" &
done

wait

printf " done.\n\n"

printf "Making gif..."

convert -delay 13 -loop 0 "${TEMP_DIRECTORY}"/*.png "${WORKING_DIRECTORY}/result.gif"

printf " done.\n"

rm -rf "${TEMP_DIRECTORY}" &
