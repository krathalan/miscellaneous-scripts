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
readonly GREEN=$(tput setaf 2)
readonly RED=$(tput bold && tput setaf 1)
readonly NC=$(tput sgr0) # No color/turn off all tput attributes

# Other
readonly SCRIPT_START_TIME="$(date +%s)"
readonly RESULTS_FILE="${PWD}/results-${SCRIPT_START_TIME}.txt"
readonly SCRIPT_NAME="${0##*/}"
readonly SCRIPT_URL="https://git.sr.ht/~krathalan/miscellaneous-scripts"

# ---------> Edit this! <---------
readonly COMPRESSION_CONFIGS_TO_TEST=(
  "lzop -1" "lzop -3"
  "xz -3" "xz -6" "xz -9"
  "pigz -3" "pigz -6" "pigz -9"
  "lz4 -1" "lz4 -3" "lz4 -5" "lz4 -9"
  "brotli -1" "brotli -3" "brotli -5" "brotli -7" "brotli -9"
  "pzstd -10" "pzstd -12" "pzstd -15" "pzstd -17" "pzstd -19"
)

# Also used for displaying calculations.
readonly TMP_DIR="$(mktemp -d -t "${SCRIPT_NAME}.XXXXXXXX")"
readonly TMP_FILE_FFS="${TMP_DIR}/finalfilesize.txt"
readonly TMP_FILE_SPPC="${TMP_DIR}/secondsperpointofcompression.txt"
readonly TMP_FILE_DECOMP="${TMP_DIR}/decompression.txt"
touch "${TMP_FILE_FFS}" "${TMP_FILE_SPPC}" "${TMP_FILE_DECOMP}"
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

find_best()
{
  local best=""
  local bestRank="$(( $(wc -l "${TMP_FILE_FFS}" | cut -d' ' -f1) * 2 ))"
  local currentRank=0
  local lineArray=()

  for config in "${COMPRESSION_CONFIGS_TO_TEST[@]}"; do
    # Grep each compression config from the $RESULTS_FILE into an array
    mapfile -t lineArray <<< "$(grep "${config}" "${RESULTS_FILE}")"

    # Just get the rank of the compression config from each file
    for line in "${lineArray[@]}"; do
      # e.g. "12. 128.14 MB `pigz -6 -k` (CR: 26.18%; T: 3.01s; SPPC: 0.041 s/pc)"
      # becomes "12". then add it to the currentRank
      currentRank=$(( currentRank + ${line%%.*} ))
    done

    if [[ "${currentRank}" -lt "${bestRank}" ]]; then
      bestRank="${currentRank}"
      best="${config}"
    fi

    # Reset rank
    currentRank=0
  done

  printf "%s" "${best}"
}

round_to_two_decimals()
{
  printf "%.2f" "$1"
}

round_to_three_decimals()
{
  printf "%.3f" "$1"
}

# $1: file
# $2: message
rank_results()
{
  local -r file="$1"
  local -r message="$2"

  sort --output="${file}" --numeric-sort "${file}"
  mapfile -t fileContents < "${file}"

  printf "\nResults, ranked by %s (lower is better):\n" "${message}" | tee -a "${RESULTS_FILE}"

  local counter=0
  for line in "${fileContents[@]}"; do
    counter=$(( counter + 1 ))
    printf "%s. %s\n" "${counter}" "${line}" | tee -a "${RESULTS_FILE}"
  done
}

test_compression()
{
  local compressionProgram="$1"

  # Get 'base' command; e.g. 'xz -1 -k --threads=0' becomes just 'xz'
  local fileExt="${compressionProgram%% *}"

  # Correct some fileExt;
  # keep the original file when using xz, pigz, and gzip;
  # and turn on multithreading for xz
  case "${fileExt}" in
    brotli)
      fileExt="br"
      ;;
    gzip|pigz)
      fileExt="gz"
      compressionProgram="${compressionProgram} -k"
      ;;
    lzop)
      fileExt="lzo"
      ;;
    xz*)
      compressionProgram="${compressionProgram} -k --threads=0"
      ;;
    *zstd)
      fileExt="zst"
      ;;
    *)
      ;;
  esac

  printf "Executing: %s\n" "${compressionProgram} ${TAR_FILE}"

  # Leftovers?
  [[ -f "${TAR_FILE}.${fileExt}" ]] &&
    rm -f "${TAR_FILE}.${fileExt}"

  # Execute and measure execution time in milliseconds
  local startTime
  startTime="$(date +%s%N | cut -b1-13)"

  ${compressionProgram} "${TAR_FILE}"

  local endTime
  endTime="$(date +%s%N | cut -b1-13)"
  local time="$(( endTime - startTime ))"

  # Change time to seconds (two decimal places) for nice printing
  time="$(echo "${time}/1000" | bc -l)"
  time="$(round_to_two_decimals "${time}")"

  # Get final file size in bytes
  local -r finalFileSize="$(du -scb "${TAR_FILE}.${fileExt}" | head -n1 | awk '{printf $1}')"

  # Calculate compression ratio as a percentage value for nice printing
  local ratio
  ratio="$(echo "(${finalFileSize} / ${ORIGINAL_FILE_SIZE}) * 100" | bc -l)"
  ratio="$(round_to_two_decimals "${ratio}")"

  # Get final file size in MB for nice printing
  local finalFileSizeInMB
  finalFileSizeInMB="$(echo "${finalFileSize} / 1000000" | bc -l)"
  finalFileSizeInMB="$(round_to_two_decimals "${finalFileSizeInMB}")"

  # Calculate seconds spent per point of compression
  # First, calculate how much of the file was "removed" in percentage
  percentageRemoved="$(echo "100 - ${ratio}" | bc -l)"
  # Then divide time by the percentage removed
  secondsPerPointOfCompression="$(echo "${time} / ${percentageRemoved}" | bc -l)"
  secondsPerPointOfCompression="$(round_to_three_decimals "${secondsPerPointOfCompression}") s/pc"

  # Label units :)
  time="${time}s"

  # Print result to terminal during testing
  printf "\nFinal file size: %s MB\nCompression ratio: %s\nTime to compress: %s\nSeconds per point of compression: %s\n" "${finalFileSizeInMB}" "${ratio}%" "${time}" "${secondsPerPointOfCompression}"

  # Print result to $TMP_FILEs for final summary
  # Sorted by final file size
  printf "%s MB \`%s\` (CR: %s; T: %s; SPPC: %s)\n" "${finalFileSizeInMB}" "${compressionProgram}" "${ratio}%" "${time}" "${secondsPerPointOfCompression}" >> "${TMP_FILE_FFS}"
  # Sorted by seconds per point of compression
  printf "%s \`%s\` (CR: %s; T: %s; FFS: %s MB)\n" "${secondsPerPointOfCompression}" "${compressionProgram}" "${ratio}%" "${time}" "${finalFileSizeInMB}" >> "${TMP_FILE_SPPC}"

  # Measure decompression
  printf "\nExecuting: %s\n" "${compressionProgram// *} -d ${TAR_FILE}.${fileExt}"

  # Delete original file, some programs will "fail" if there is already
  # a .tar present
  rm -rf "${TAR_FILE}"

  # Execute and measure execution time in milliseconds
  startTime="$(date +%s%N | cut -b1-13)"

  ${compressionProgram// *} -d "${TAR_FILE}.${fileExt}"

  endTime="$(date +%s%N | cut -b1-13)"
  time="$(( endTime - startTime ))"

  # Change time to seconds (two decimal places) for nice printing
  time="$(echo "${time}/1000" | bc -l)"
  time="$(round_to_two_decimals "${time}")"
  # Label units :)
  time="${time}s"

  # Print result to terminal during testing
  printf "\nDecompression time: %s\n" "${time}"

  # Print result to $TMP_FILEs for final summary
  printf "%s \`%s\`\n" "${time}" "${compressionProgram}" >> "${TMP_FILE_DECOMP}"

  # Delete output file
  rm -rf "${TAR_FILE}.${fileExt}"
}

# -----------------------------------------
# ---------------- Script -----------------
# -----------------------------------------

if [[ "$(whoami)" = "root" ]]; then
  exit_script_on_failure "This script should NOT be run as root (or sudo)!"
fi

[[ $# -eq 0 ]] &&
  exit_script_on_failure "Please specify a folder to benchmark compression of."

if [[ -d "$1" ]]; then
  # Get base path of folder; e.g. /home/user/folder/xxx/ becomes xxx
  FOLDER="${1%/}"
  readonly TAR_FILE="${FOLDER##*/}.tar"
  printf "Tarring directory %s...\n" "${FOLDER}"
  tar -cf "${TAR_FILE}" "${FOLDER}"
else
  readonly TAR_FILE="$1"
fi

# Get original file size so we don't have to keep recalculating it
readonly ORIGINAL_FILE_SIZE="$(du -scb "${TAR_FILE}" | tail -n1 | awk '{printf $1}')"

# Test all configs
counter=0
while [[ "${counter}" -lt "${#COMPRESSION_CONFIGS_TO_TEST[@]}" ]]; do
  printf "\n%sRunning test %s/%s%s\n" "${GREEN}" "$(( counter + 1 ))" "${#COMPRESSION_CONFIGS_TO_TEST[@]}" "${NC}"
  test_compression "${COMPRESSION_CONFIGS_TO_TEST[counter]}"

  counter="$(( counter + 1 ))"
done

# Done testing :)
# Get original file size in MB for nice printing
originalFileSizeInMB="$(echo "${ORIGINAL_FILE_SIZE} / 1000000" | bc -l)"
originalFileSizeInMB="$(round_to_two_decimals "${originalFileSizeInMB}")"

# Print test info to $RESULTS_FILE
printf "Compression testing for %s\nOriginal file size: %s MB\nDate: %s\nCompleted by %s\n%s\n" "${TAR_FILE}" "${originalFileSizeInMB}" "$(date "+%b %d %Y %I:%M%P")" "${SCRIPT_NAME}" "${SCRIPT_URL}" > "${RESULTS_FILE}"

# Print final summary
readonly SCRIPT_END_TIME="$(date +%s)"
readonly SCRIPT_TOTAL_TIME="$(( SCRIPT_END_TIME - SCRIPT_START_TIME ))"

printf "\n-------------------------------------------"
printf "\nTotal time to complete all tests: %s seconds\n" "${SCRIPT_TOTAL_TIME}" | tee -a "${RESULTS_FILE}"

rank_results "${TMP_FILE_FFS}" "final file size"
rank_results "${TMP_FILE_SPPC}" "seconds per point of compression"

bestCompression="$(find_best)"

rank_results "${TMP_FILE_DECOMP}" "decompression time"

bestCompressionAndDecompression="$(find_best)"

printf "\nBest config for frequent compression and infrequent decompression: %s\n" "${bestCompression}" | tee -a "${RESULTS_FILE}"

printf "\nBest config for frequent compression and frequent decompression: %s\n" "${bestCompressionAndDecompression}" | tee -a "${RESULTS_FILE}"