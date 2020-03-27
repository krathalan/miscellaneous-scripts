#!/usr/bin/env sh
#
# Description: Checks all sh and bash scripts in the current directory
#              with shellcheck.
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
set -u # (Eo pipefail) is Bash only!

# No "set -e" because this script should continue if shellcheck "fails" when
# printing errors in a script

# -----------------------------------------
# ----------- Program variables -----------
# -----------------------------------------

# Colors
readonly RED=$(tput bold && tput setaf 1)
readonly GREEN=$(tput bold && tput setaf 2)
readonly WHITE=$(tput sgr0 && tput bold)
readonly NC=$(tput sgr0) # No color/turn off all tput attributes

# Other
readonly SCRIPT_NAME=$(basename "$0")

# Step variables
stepCounter=1

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

#######################################
# Properly formats a step statement.
# Globals:
#   stepCounter, GREEN, NC, WHITE
# Arguments:
#   none
# Returns:
#   none
#######################################
print_step()
{
  printf "%s==> %s%s. %s%s" "${GREEN}" "${WHITE}" "${stepCounter}" "$1" "${NC}"
}

# -----------------------------------------
# ---------------- Script -----------------
# -----------------------------------------

if [ "$(whoami)" = "root" ]; then
  exit_script_on_failure "This script should NOT be run as root (or sudo)!"
fi

printf "Checking scripts in working directory...\n\n"

# Get the file name without the full path
fileName=""

for file in "${PWD}"/*; do
  if [ ! -d "${file}" ] && head -n1 "${file}" | grep -q "\#\!/.*sh"; then
    fileName="$(realpath --relative-to="${PWD}" "${file}")"
    print_step "${fileName}"

    shellcheck "${file}"

    printf "\n\n"
    stepCounter=$(( stepCounter + 1 ))
  fi
done

printf "Done.\n"
