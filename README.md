# Krathalan's Scripts
This repository is a collection of scripts I wrote and use/modify regularly. These scripts are provided without warranty in the hope that you will find them useful. Contributions are accepted, just open an issue or a pull request.

Please don't run these scripts without reading them first. Always read a script before running it on your machine, especially if it requires sudo/root privileges.

## make_gif
I made this script after the camera app I use on my phone lost it's auto-gif-making functionality whenever I would take burst photos. To use it, put only the photos you want in the gif into a directory, and then run the script in that directory.

## save_installed_packages_log
This script will save a list of your explicitly installed packages to `/var/log/installed_packages.log`. It's meant to be used in a pacman hook in `/etc/pacman.d/hooks/`, like this:

```
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=*

[Action]
Description=Saving list of installed packages to /var/log/installed_packages.log...
When=PostTransaction
NeedsTargets
Exec=/path/to/where/you/put/this/script
```

## setup_linux
This script sets up Arch Linux with my programs and configures a few things for me automatically. You don't want to run this script without reading through it and changing it to your liking. 

## system_maintenance
This script will perform system maintenance on an Arch Linux system. You must have the yay package installed from the AUR (https://github.com/Jguer/yay). It will:

- Update `/etc/pacman.d/mirrorlist` if it hasn't been updated in more than 3.5 days
  - This functionality requires the [reflector](https://www.archlinux.org/packages/community/any/reflector/) package to be installed
- Update installed packages and remove unused packages
- Clean pacman and yay caches
- Check your pacman database
- Update installed flatpaks and remove unused flatpaks (if you have the flatpak package installed)
- Empty your trash
- Print disk usage
  - This functionality requires the [neofetch](https://www.archlinux.org/packages/community/any/neofetch/) package to be installed 

## update_dxvk
This script will place the version of DXVK you tell it to download in `~/.local/bin`. For example, if you run the command `bash update_dxvk 1.2`, the script will download (from DXVK's GitHub releases) and extract version 1.2 of DXVK to `~/.local/bin/dxvk-1.2`.

## update_git_repos
This script will `git pull` for every Git repository in `~/Git`. The script will automatically determine whatever branch the repository is on and pull that branch. For example, if I had a Git repository at `~/Git/miscellaneous-scripts` on the branch "testing", and I ran the update_git_repos script, the script would run `git pull origin testing` in the `~/Git/miscellaneous-scripts` directory.