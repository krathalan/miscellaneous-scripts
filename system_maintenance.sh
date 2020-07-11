#!/usr/bin/env sh
#
# Description: Performs regular Arch Linux system maintenance procedures.
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

# Other
readonly SCRIPT_NAME=$(basename "$0")

# -----------------------------------------
# ------------- User variables ------------
# -----------------------------------------

regenerateMirrorlist="true"

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

# Use doas if sudo is not present
rootCommand="sudo"

if [ ! -x "$(command -v "sudo")" ]; then
  rootCommand="doas --"
fi

# Parse flags. From:
# https://stackoverflow.com/questions/7069682/how-to-get-arguments-with-flags-in-bash/7069755#7069755
while test $# -gt 0; do
  case "$1" in
    -c|--clean)
      printf "\n%s. Cleaning pacman caches...\n" "${stepWithColor}"
      ${rootCommand} pacman -Sc --noconfirm || exit_script_on_failure "Problem cleaning pacman caches with command \"pacman -Sc --noconfirm\""
      printf "Done.\n"
      exit 0
      ;;
    -n|--no-mirrorlist-refresh)
      export regenerateMirrorlist="false"
      shift
      ;;
    *)
      break
      ;;
  esac
done

if [ "$(whoami)" = "root" ]; then
  exit_script_on_failure "This script should NOT be run as root (or ${rootCommand})!"
fi

if [ "${regenerateMirrorlist}" = "true" ] && [ -x "$(command -v "reflector")" ]; then
  # Check last mirror list update time
  mirrorListUpdateTime=$(grep "Last Check" /etc/pacman.d/mirrorlist | awk '{printf $4}')

  if [ -n "${mirrorListUpdateTime}" ]; then
    mirrorListUpdateTime=$(date +%s -d "${mirrorListUpdateTime}") # Convert to Unix time
  fi

  readonly currentTime=$(date +%s -d now) # Get current time as Unix time

  # 302400 = half the number of seconds in a week
  if [ -z "${mirrorListUpdateTime}" ] || [ $(( currentTime - mirrorListUpdateTime )) -gt 302400 ]; then
    printf "\n%s. Regenerating mirrorlist...\n" "${stepWithColor}"
    ${rootCommand} reflector --latest 8 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    complete_step

    printf "\nNew mirrorlist in /etc/pacman.d/mirrorlist:\n"
    grep "Server" /etc/pacman.d/mirrorlist

    printf "\n%s. Updating packages...\n" "${stepWithColor}"

    # Two "y"s in -Syyu forces pacman to update the repos even if they appear to be up to date;
    # this should be used only after updating the mirrorlist
    # https://wiki.archlinux.org/index.php/Mirrors#Force_pacman_to_refresh_the_package_lists
    ${rootCommand} pacman -Syyu
    complete_step
  else
    printf "\n%s. Updating packages...\n" "${stepWithColor}"
    ${rootCommand} pacman -Syu
    complete_step
  fi
else
  printf "\n%s. Updating packages...\n" "${stepWithColor}"
  ${rootCommand} pacman -Syu
  complete_step
fi

if [ -x "$(command -v "aur")" ]; then
  printf "\n%s. Checking for local package updates from the AUR...\n" "${stepWithColor}"
  aur check --quiet
  complete_step
fi

printf "\n%s. Removing unused packages...\n" "${stepWithColor}"
if pacman -Qttdq > /dev/null; then
  # Disable this shellcheck as we want words to split here
  # shellcheck disable=SC2046
  ${rootCommand} pacman -Rs $(pacman -Qttdq)
else
  printf "No packages to remove.\n"
fi
complete_step

printf "\n%s. Removing system journal entries older than one day...\n" "${stepWithColor}"
${rootCommand} journalctl --vacuum-time=1d
complete_step

if [ -x "$(command -v "flatpak")" ]; then
  printf "\n%s. Updating Flatpaks...\n" "${stepWithColor}"
  flatpak update -y
  complete_step
fi

printf "\n%s. Checking pacman database...\n" "${stepWithColor}"
${rootCommand} pacman -Dk
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

if [ -x "$(command -v "version-check")" ]; then
  printf "\n%s. Checking AppArmor profile versions against installed package versions...\n" "${stepWithColor}"
  version-check -q
  complete_step
fi

printf "\n%s. Printing root disk usage...\n" "${stepWithColor}"

# Get root partition info
rootPartitionInfo="$(df -h | grep -G ".*/$")"

if glob "${rootPartitionInfo}" "/dev/mapper*"; then
  printf "%s/%s, %s full\n" "$(printf "%s" "${rootPartitionInfo}" | cut -d' ' -f6)" "$(printf "%s" "${rootPartitionInfo}" | cut -d' ' -f3)" "$(printf "%s" "${rootPartitionInfo}" | cut -d' ' -f10)"
else
  printf "%s/%s, %s full\n" "$(printf "%s" "${rootPartitionInfo}" | cut -d' ' -f12)" "$(printf "%s" "${rootPartitionInfo}" | cut -d' ' -f10)" "$(printf "%s" "${rootPartitionInfo}" | cut -d' ' -f17)"
fi

complete_step
