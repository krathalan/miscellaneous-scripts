#!/usr/bin/env sh
#
# Description: Performs regular Arch Linux system maintenance procedures.
#
# Homepage: https://git.sr.ht/~krathalan/miscellaneous-scripts
#
# Copyright (C) 2019-2020 Hunter Peavey
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
#
# This file incorporates work from https://github.com/dylanaraps/pash,
# covered by the following copyright and permission notice:
#
#     Copyright (c) 2016-2019, Dylan Araps
#
#     Permission is hereby granted, free of charge, to any person obtaining a copy
#     of this software and associated documentation files (the "Software"), to deal
#     in the Software without restriction, including without limitation the rights
#     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#     copies of the Software, and to permit persons to whom the Software is
#     furnished to do so, subject to the following conditions:
#
#     The above copyright notice and this permission notice shall be included in all
#     copies or substantial portions of the Software.
#
#     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#     SOFTWARE.

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
readonly PURPLE=$(tput bold && tput setaf 5)
readonly NC=$(tput sgr0) # No color/turn off all tput attributes

# Step variables
stepCounter=1
stepWithColor="${PURPLE}${stepCounter}${NC}"

# -----------------------------------------
# --------------- Functions ---------------
# -----------------------------------------

#######################################
# Checks to see if a specified command is available.
# Globals:
#   none
# Arguments:
#   $1: command to test
# Returns:
#   none
#######################################
check_command()
{
  if [ -z "$(command -v "$1")" ]; then
    return 1
  else
    return 0
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
  exit 1
}

#######################################
# This is a simple wrapper around a case statement to allow
# for simple string comparisons against globs.
# Copyright (C) 2016-2019 Dylan Araps
# Globals:
#   none
# Arguments:
#   $1: string to check against glob
#   $2: glob
# Returns:
#   true or false
#######################################
glob() {
  # Disable this warning as it is the intended behavior.
  # shellcheck disable=2254
  case $1 in $2) return 0; esac; return 1
}

#######################################
# Properly configures stepWithColor.
# Globals:
#   stepCounter, stepWithColor, PURPLE, NC
# Arguments:
#   none
# Returns:
#   none
#######################################
complete_step()
{
  stepCounter=$(( stepCounter + 1 ))
  stepWithColor="${PURPLE}${stepCounter}${NC}"
}

# -----------------------------------------
# ---------------- Script -----------------
# -----------------------------------------

# Parse flags. From:
# https://stackoverflow.com/questions/7069682/how-to-get-arguments-with-flags-in-bash/7069755#7069755
while test $# -gt 0; do
  case "$1" in
    -c|--clean)
      printf "\n%s. Cleaning pacman caches...\n" "${stepWithColor}"
      sudo pacman -Sc --noconfirm
      printf "Done.\n"
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

[ "$(whoami)" = "root" ] &&
  exit_script_on_failure "This script should NOT be run as root (or sudo)!"

printf "\n%s. Updating packages...\n" "${stepWithColor}"
sudo pacman -Syu
complete_step

# The reason I grep for krathalan here is because the popular aurutils
# project also contains a /usr/bin/aur
if check_command kaur; then
  printf "\n%s. Checking for local package updates from the AUR...\n" "${stepWithColor}"
  kaur check --quiet
  complete_step
fi

printf "\n%s. Removing unused packages...\n" "${stepWithColor}"
if pacman -Qttdq > /dev/null; then
  # Disable this shellcheck as we want words to split here
  # shellcheck disable=SC2046
  sudo pacman -Rs $(pacman -Qttdq)
else
  printf "No packages to remove.\n"
fi
complete_step

printf "\n%s. Removing system journal entries older than one day...\n" "${stepWithColor}"
sudo journalctl --vacuum-time=1d
complete_step

if check_command flatpak; then
  printf "\n%s. Updating Flatpaks...\n" "${stepWithColor}"
  sudo flatpak update -y
  complete_step
fi

printf "\n%s. Checking pacman database...\n" "${stepWithColor}"
sudo pacman -Dk
complete_step

printf "\n%s. Listing failed systemd units...\n" "${stepWithColor}"
systemctl --failed
complete_step

printf "\n%s. Listing *.pacsave and *.pacnew files in /etc...\n" "${stepWithColor}"
printf "%s" "${RED}"
find /etc -name "*.pacsave" 2> /dev/null || true
find /etc -name "*.pacnew" 2> /dev/null || true
printf "%s" "${NC}"
complete_step

if check_command version-check; then
  printf "\n%s. Checking AppArmor profile versions against installed package versions...\n" "${stepWithColor}"
  version-check -q
  complete_step
fi

printf "\n%s. Printing root disk usage...\n" "${stepWithColor}"

# Get root partition info
rootPartitionInfo="$(df -h | grep -G ".*/$")"

printf "%s/%s, %s full\n" "$(printf "%s" "${rootPartitionInfo}" | awk '{printf $3}')" "$(printf "%s" "${rootPartitionInfo}" | awk '{printf $2}')" "$(printf "%s" "${rootPartitionInfo}" | awk '{printf $5}')"

complete_step
