#!/bin/bash

args=('-H' '--no-hostonly-cmdline')

while read -r line; do
    if [[ $line = usr/lib/modules/+([^/])/pkgbase ]]; then
        mapfile -O ${#pkgbase[@]} -t pkgbase < "/$line"
        kver=${line#"usr/lib/modules/"}
        kver=${kver%"/pkgbase"}
    fi
done

dracut "${args[@]}" -f /boot/initramfs-"${pkgbase[@]}".img --kver "${kver[@]}"
#dracut -f /boot/initramfs-"${pkgbase[@]}"-fallback.img --kver "${kver[@]}"
