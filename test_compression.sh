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
readonly RESULTS_FILE="${PWD}/results.json"
readonly SCRIPT_NAME="${0##*/}"
readonly SCRIPT_START_TIME="$(date +%s)"

# ---------> Edit this! <---------
readonly COMPRESSION_CONFIGS_TO_TEST=(
  "lz4 -1" "lz4 -3" "lz4 -5"
  "pzstd -3" "pzstd -6" "pzstd -9"
  "xz -2" "xz -4" "xz -6"
)

# Used when displaying calculations at the end.
# Adjust this lower to value time (e.g. a value of 2), or higher to value
# compression (e.g. a value of 20).
readonly WR_EXPONENT=10

# Also used for displaying calculations.
readonly TMP_DIR="$(mktemp -d -t "${SCRIPT_NAME}.XXXXXXXX")"
readonly TMP_FILE="${TMP_DIR}/out.txt"
touch "${TMP_FILE}"
trap 'rm -rf "${TMP_DIR}"' EXIT SIGINT

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

test_compression()
{
  local compression_program="$1"
  if [[ "${compression_program}" == "xz"* ]]; then 
    compression_program="${compression_program} -k --threads=0"
  fi
  
  # Get 'base' command; e.g. 'xz -1 -k --threads=0' becomes just 'xz'
  local file_ext="${compression_program%% *}"
  if [[ "${file_ext}" == *"zstd" ]]; then
    file_ext="zst"
  fi

  printf "Running: %s\n" "${compression_program} ${TAR_FILE}"

  # Leftovers from previous compressions....
  [[ -f "${TAR_FILE}.${file_ext}" ]] &&
    rm -f "${TAR_FILE}.${file_ext}"

  local -r start_time="$(date +%s)"
  ${compression_program} "${TAR_FILE}"
  local -r end_time="$(date +%s)"
  local -r time="$(( end_time - start_time ))"
  local -r ratio="$(echo "$(du -sc "${TAR_FILE}.${file_ext}" | tail -n1 | awk '{printf $1}') / $(du -sc "${TAR_FILE}" | tail -n1 | awk '{printf $1}')" | bc -l)"

  # Calculate weighted rating
  local -r weighted_rating="$(echo "1/(${time}*(${ratio}^${WR_EXPONENT}))" | bc -l)"

  # Lets write some json.... -:|
  local -r tmpJson="$(jq ".results[.results | length] |= . + {\"program\":\"${compression_program}\",\"time\":\"${time}\",\"ratio\":\"${ratio}\",\"weighted_rating\":\"${weighted_rating}\"}" "${RESULTS_FILE}")"
  printf "%s" "${tmpJson}" > "${RESULTS_FILE}"

  printf "%.2f \`%s\` (CR: %.2f; T: %ss)\n" "${weighted_rating}" "${compression_program}" "${ratio}" "${time}" >> "${TMP_FILE}"

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

[[ -f "${RESULTS_FILE}" ]] &&
  exit_script_on_failure "${RESULTS_FILE##*/} file already found. Please rename it or delete it."

# Create skeleton RESULTS_FILE
printf "{\"results\":[]}" > "${RESULTS_FILE}"

if [[ "$1" == *".tar" ]]; then
  readonly TAR_FILE="$1"
else
  readonly FOLDER="$1"
  readonly TAR_FILE="$(basename "$1").tar"
  printf "Tarring...\n"
  tar -cf "${TAR_FILE}" "${FOLDER}"
fi

for config in "${COMPRESSION_CONFIGS_TO_TEST[@]}"; do
  test_compression "${config}"
done

readonly SCRIPT_END_TIME="$(date +%s)"

if [[ "${#COMPRESSION_CONFIGS_TO_TEST[@]}" -gt 1 ]]; then
  readonly SCRIPT_TOTAL_TIME="$(( SCRIPT_END_TIME - SCRIPT_START_TIME ))"
  printf "\n\n----------------------------------------\nTotal time to complete all tests: %s seconds\n\n" "${SCRIPT_TOTAL_TIME}"
  printf "%s" "\
How to interpret results:
Lower compression ratios (CR) and lower (faster) times (T) are better.
Weighted rating (WR) favors compression program/levels that are on the faster
side but still maintain a good compression ratio. You should not compare WR or
compression ratios across files; they should only be compared to each other
when they are calculated from compressing the same original file.
"

  # Rank results by their WR
  sort -o "${TMP_FILE}" -n -r "${TMP_FILE}"
  mapfile -t toPrint < "${TMP_FILE}"
  counter=0

  printf "\nResults, ranked by WR:\n"
  for line in "${toPrint[@]}"; do
    counter=$(( counter + 1 ))
    printf "%s. %s\n" "${counter}" "${line}"
  done
fi