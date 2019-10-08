#!/bin/bash
#
# Description: Generates a new initramfs with dracut. To be used in the interim
#              until official dracut ALPM hooks are provided.
#
# Homepage: https://gitlab.com/krathalan/miscellaneous-scripts
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
set -Eeuo pipefail

# -----------------------------------------
# ---------------- Script -----------------
# -----------------------------------------

outputfilename="/boot/initramfs-linux"
read -r kver
kver=${kver#"usr/lib/modules/"}
kver=${kver%"/vmlinuz"}

if grep -q "lts" <<< "${kver}"; then
  outputfilename="${outputfilename}-lts-dracut.img"
else
  outputfilename="${outputfilename}-dracut.img"
fi

dracut --stdlog 4 --omit "network iscsi stratis" --hostonly --lz4 -f "${outputfilename}" --kver "${kver}"
