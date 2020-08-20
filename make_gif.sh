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

# Clean up tmp dir on exit
trap "clean_up" INT EXIT

# -----------------------------------------
# ----------- Program variables -----------
# -----------------------------------------

readonly SCRIPT_NAME="${0##*/}"
readonly TMP_DIR="$(mktemp -d -t "${SCRIPT_NAME}_XXXXXXXX")"

# Colors
readonly RED=$(tput bold && tput setaf 1)
readonly NC=$(tput sgr0) # No color/turn off all tput attributes

# -----------------------------------------
# --------------- Functions ---------------
# -----------------------------------------

clean_up()
{
  rm -rf "${TMP_DIR}"
}

downsize_image()
{
  if printf "%s" "$1" | grep -q ".*\.gif$"; then
    printf "%s is a gif, skipping\n" "$1"
    return
  fi

  if identify "$1" > /dev/null 2>&1; then
    convert "$1" -resize 13% "${TMP_DIR}/$1"
  else
    printf "%s is not an image file, skipping\n" "$1"
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

printf "\nResizing images...\n"

for image in ./*; do
  downsize_image "${image}" &
done

wait

printf "Done.\n\n"

[ -z "$(find "${TMP_DIR}" -type f)" ] &&
  exit_script_on_failure "No image files found"

printf "Making gif...\n"

readonly OUTPUT_FILE_BASE="result"
outputFile="result"
whileCounter=1

while [ -f "${outputFile}.gif" ]; do
  outputFile="${OUTPUT_FILE_BASE}${whileCounter}"
  whileCounter="$(( whileCounter + 1 ))"
done

outputFile="${outputFile}.gif"
convert -delay 13 -loop 0 "${TMP_DIR}"/* "${PWD}/${outputFile}"

printf "Done. Output file %s\n" "${outputFile}"
