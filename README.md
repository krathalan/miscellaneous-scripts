# Krathalan's Scripts
This repository is a collection of scripts I wrote and use/modify regularly. These scripts are provided without warranty in the hope that you will find them useful. Contributions are accepted, just open an issue or a pull request.

Please don't run these scripts without reading them first. Always read a script before running it on your machine, especially if it requires sudo/root privileges.

Seven POSIX-compliant sh scripts, three Bash scripts.

## gather_time_data (bash)
This script will gather execution time data for a specified command and return the average execution time. Helpful for testing optimizations in other scripts. For example, testing [wtwitch](https://gitlab.com/krathalan/wtwitch) optimizations with `gather_time_data "wtwitch -g overwatch"` would print out:

```
Running command 15 times, please be patient...

Execution 1 completed in 4201 milliseconds
Execution 2 completed in 3511 milliseconds
Execution 3 completed in 3339 milliseconds
Execution 4 completed in 3400 milliseconds
Execution 5 completed in 3517 milliseconds
Execution 6 completed in 3692 milliseconds
Execution 7 completed in 3177 milliseconds
Execution 8 completed in 3770 milliseconds
Execution 9 completed in 3118 milliseconds
Execution 10 completed in 3864 milliseconds
Execution 11 completed in 3962 milliseconds
Execution 12 completed in 3332 milliseconds
Execution 13 completed in 3213 milliseconds
Execution 14 completed in 3255 milliseconds
Execution 15 completed in 3363 milliseconds

Average execution time: 3.51 seconds
```

## make_gif (sh)
I made this script after the camera app I use on my phone lost it's auto-gif-making functionality whenever I would take burst photos. To use it, put only the photos you want in the gif into a directory, and then run the script in that directory.

Here's an example gif of my cat I made with make_gif:

![Example gif](Images/example.gif)

## prntscrn (sh)
Takes a nice screenshot after the specified seconds and saves it to `~/Pictures/Screenshots`. Displays a notification when the screenshot is taken. Easily bound to a key in your i3 config.

## save_installed_packages_log (bash)
This script will save a comprehensive, organized list of installed packages to `/var/log/installed_packages.log`. It's meant to be used in a pacman hook in `/etc/pacman.d/hooks/`, like this:

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
Exec=/path/to/where/you/put/this/script/save_installed_packages_log
```

## script_template (sh)
A simple POSIX-compliant script template I use. Easy to use as a Bash script template as well.

## setup_linux (sh)
This script sets up Arch Linux with the programs I use and configures a few things for me automatically. You don't want to run this script without reading through it and changing it to your liking. 

## system_maintenance (sh)
This script will perform system maintenance on an Arch Linux system. You must have the yay package installed from the AUR (https://github.com/Jguer/yay). It will:

- Update `/etc/pacman.d/mirrorlist` if it hasn't been updated in more than 3.5 days
  - This functionality requires the [reflector](https://www.archlinux.org/packages/community/any/reflector/) package to be installed
  - If you have the `firefox-nightly` package installed, this script will update it along with the mirrorlist
- Update installed packages and remove unused packages
- Clean pacman and yay caches
- Check your pacman database
- Update installed flatpaks and remove unused flatpaks
  - This functionality requires the [flatpak](https://www.archlinux.org/packages/extra/x86_64/flatpak/) package to be installed
- Empty your trash
- Print disk usage
  - This functionality requires the [neofetch](https://www.archlinux.org/packages/community/any/neofetch/) package to be installed 

## update_dxvk (sh)
This script will place the version of DXVK you tell it to download in `~/.local/bin`. For example, if you run the command `sh update_dxvk 1.2`, the script will download DXVK version 1.2 (from [DXVK's GitHub releases](https://github.com/doitsujin/dxvk/releases)) and extract it to `~/.local/bin/dxvk-1.2`.

## update_git_repos (bash)
This script will `git pull` inside every Git repository in `~/Git`. The script will automatically determine whatever branch the repository is on and pull that branch. For example, if I had a Git repository at `~/Git/miscellaneous-scripts` on the branch "testing", and I ran the update_git_repos script, the script would run `git pull origin testing` in the `~/Git/miscellaneous-scripts` directory.

This script will skip any directory ending in ".git".

# vpn_detect (sh)
This script takes the name of a VPN interface, like "mullvad-us3", and returns a `.json` file containing information on the state of the VPN connection. This script is meant to be used in a [waybar](https://github.com/Alexays/Waybar) module, like this:

```
"custom/vpn": {
  "interval": 5,
  "tooltip": false,
  "format": "{}",
  "return-type": "json",
  "exec": "bash /path/to/vpn_detect mullvad-us3"
}
```
