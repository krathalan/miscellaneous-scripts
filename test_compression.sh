#!/usr/bin/env bash
#
# Description: Benchmark compression on a folder.
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
set -Eeuo pipefail

# -----------------------------------------
# ----------- Program variables -----------
# -----------------------------------------

# Colors
readonly RED=$(tput bold && tput setaf 1)
readonly NC=$(tput sgr0) # No color/turn off all tput attributes

# Other
readonly SCRIPT_NAME="${0##*/}"

# -----------------------------------------
# ------------- User variables ------------
# -----------------------------------------

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

test_compression()
{
  local compression_program="$1"
  if [[ "${compression_program}" == "xz" ]]; then 
    compression_program="${compression_program} -k --threads=0 -1"
  fi
  local file_ext="$1"
  if [[ "${file_ext}" == *"zstd" ]]; then
    file_ext="zst"
  fi

  printf "Running: %s\n" "${compression_program} ${TAR_FILE}"

  local -r start_time="$(date +%s)"
  ${compression_program} "${TAR_FILE}"
  local -r end_time="$(date +%s)"
  local -r time="$(( end_time - start_time ))"
  local -r ratio="$(echo "$(du -sc "${TAR_FILE}.${file_ext}" | tail -n1 | awk '{printf $1}') / $(du -sc "${TAR_FILE}" | tail -n1 | awk '{printf $1}')" | bc -l)"

  printf "\n%s compression ratio: %.2f\nTime to compress: %s seconds\n\n" "$1" "${ratio}" "${time}"

  rm -rf "${TAR_FILE}.${file_ext}"
}

# -----------------------------------------
# ---------------- Script -----------------
# -----------------------------------------

if [[ "$(whoami)" = "root" ]]; then
  exit_script_on_failure "This script should NOT be run as root (or sudo)!"
fi

[[ $# -eq 0 ]] &&
  exit_script_on_failure "Please specify a folder to benchmark compression of."

readonly FOLDER="$1"
readonly TAR_FILE="$(basename "$1").tar"

printf "Tarring...\n"
tar -cf "${TAR_FILE}" "${FOLDER}"

test_compression "lz4"
test_compression "zstd"
test_compression "pzstd"

rm -rf "${TAR_FILE}"