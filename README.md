# Krathalan's Scripts
This repository is a collection of scripts I wrote and use/update regularly. These scripts are provided without warranty in the hope that you will find them useful. Contributions are accepted, just open an issue or a pull request.

Please don't run these scripts without reading them first. Always read a script before running it on your machine, especially if it requires sudo/root privileges.

Six POSIX-compliant sh scripts, seven Bash scripts. Scripts ending in `.sh` are POSIX-complaint without "Bash-isms". Scripts that are Bash-only often are because of the use of arrays.

## `audio_to_opus` (bash)
Simply specify an audio type (e.g. "mp3", "flac") and this script will convert all audio files in that directory to the opus format.

For example, if you execute `bash audio_to_opus flac`: all "\*.flac" files in the working directory will be converted to "\*.opus" files, all "\*.flac" files will be placed into a new "flac/" directory, again in the working directory.

## `aur` (bash)
Miniscule AUR helper.

Four functions:

```
=> [c]heck           - Check local package versions against those on the AUR.
                       Pass --quiet/-q flag to print only non-matching versions.
=> [f]etch [name(s)] - Clone git repository of [name] package(s) from the AUR.
=> [i]nfo [name]     - Show full information for a package from the AUR.
=> [s]earch [name]   - Search for packages on the AUR.
```

Note that though `aur` is licensed under the GPLv3 license, the script incorporates work Copyright (C) 2016-2019 Dylan Araps originally from MIT-licensed code from [pash](https://github.com/dylanaraps/pash). See [Maintaining Permissive-Licensed Files in a GPL-Licensed Project: Guidelines for Developers](https://softwarefreedom.org/resources/2007/gpl-non-gpl-collaboration.html) by the Software Freedom Law Center for more information.

## `check_all.sh`
Checks all shell scripts in the current directory with shellcheck.

## `gather_time_data` (bash)
This Bash script will gather execution time data for a specified command and return the average execution time. Helpful for testing optimizations in other scripts. For example, testing [wtwitch](https://git.sr.ht/~krathalan/wtwitch) optimizations with `gather_time_data "wtwitch -g overwatch"` would print out:

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

## `list_nonfree_packages` (bash)
Lists nonfree packages installed on Arch Linux according to Parabola's blacklist. Ignores packages that are blacklisted for "branding" or "technical" reasons; that is, they are not necessarily nonfree, but may conflict with Parabola's rebuilds of certain packages.

## `make_gif.sh`
I made this script after the camera app I use on my phone lost its auto-gif-making functionality whenever I would take burst photos.

To use it, put the photos you want to make into a gif into a directory, and then run the script in that directory.

Here's an example gif of my cat I made with make_gif:

![Example](https://i.imgur.com/V63J3UY.gif)

## mythic_event
A script I made for my World of Warcraft guild's Mythic+ dungeon event. Supply a list of characters, like so:

```
$ cat example_input
  Ahkenatan chogall
  Morisong chogall
  Tireiron laughing-skull
  Euphoric chogall
```

And the script will output a file `ratings.txt`, with Raider.IO information for each character in the list:

```
$ cat ratings.txt
  ======================================================
  |      Collector's Anonymous Mythic Plus Ratings     |
  |              Generated on Jun 11, 2020             |
  | https://git.sr.ht/~krathalan/miscellaneous-scripts |
  ======================================================

  IO Score -- Character, ilvl class
  =================================

  Tanks:
  1713 -- Tireiron, 475 Paladin

  Healers:
  1793 -- Euphoric, 479 Monk

  DPS:
  2136 -- Ahkenatan, 476 Mage
  1993 -- Morisong, 474 Mage
```

## `prntscrn.sh`
Takes a nice screenshot after the specified seconds and saves it to `${XDG_PICTURES_DIR}/screenshots`. Displays a notification when the screenshot is taken. Easily bound to a key in your i3 or sway config. Uses `scrot` for i3/Xorg and `grim` for sway/Wayland. Provides nice errors via desktop notifications as well if you don't have the proper package installed.

On sway/Wayland, invoking `prntscrn.sh` with any argument, like `prntscrn.sh slurp`, will allow you to select an area of the screen and will copy the selected jpeg to your clipboard.

## `remove_from_name` (bash)
This script will rename all files in the current working directory by removing a specified string from their file names.

For example:

```
$ ls
test-remove1.txt  test-remove2.txt  test-remove3.txt  test-remove4.txt  test-remove5.txt

$ remove_from_name "remove"
==> This is what the files will be renamed to:
test-1.txt
test-2.txt
test-3.txt
test-4.txt
test-5.txt

==> Proceed with renaming?
[y/N] y
Files renamed.
```

## `scramble_photos.sh`
Deletes the exif data on all photos in the current directory and attempts to restore the "datetimeoriginal" (date taken) value from the photo's file name. Then moves them to `${HOME}/pictures/$(date +%Y)`, e.g. `~/pictures/2020`; creating the folder if it doesn't exist. Pass `--no-copy` to keep them in the current directory.

## `script_template.sh`
A simple POSIX-compliant script template I use. Easy to use as a Bash script template as well.

## `system_maintenance.sh`
This script will perform system maintenance on an Arch Linux system. It will:

- Clean pacman caches (if the flag `--clean` is passed)
- Update `/etc/pacman.d/mirrorlist` if it hasn't been updated in more than 3.5 days
  - This functionality requires the [reflector](https://www.archlinux.org/packages/community/any/reflector/) package to be installed
- Update installed packages
- Check for local AUR repo updates
  - This functionality requires the [aurutils](https://aur.archlinux.org/packages/aurutils) package to be installed
- Remove unused packages
- Remove old journald entries
- Update installed flatpaks and remove unused flatpaks
  - This functionality requires the [flatpak](https://www.archlinux.org/packages/extra/x86_64/flatpak/) package to be installed
- Check your pacman database for errors
- List failed systemd units
- List `*.pacsave` and `*.pacnew` files in `/etc`
- Print disk usage
  - This functionality requires the [neofetch](https://www.archlinux.org/packages/community/any/neofetch/) package to be installed

## `update_git_repos` (bash)
This script will run `git pull --prune` inside every Git repository in the current directory.

## `update_wow_addons` (bash)
I no longer recommend using this script. Instead I recommend using Cursebreaker, as it's very well polished: https://github.com/AcidWeb/CurseBreaker
