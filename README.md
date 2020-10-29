# Krathalan's Scripts
This repository is a collection of scripts I wrote and use/update regularly. These scripts are provided without warranty in the hope that you will find them useful. Contributions are accepted, just open an issue or a pull request.

Please don't run these scripts without reading them first. Always read a script before running it on your machine, especially if it requires sudo/root privileges.

Seven POSIX-compliant sh scripts, seven Bash scripts. Scripts ending in `.sh` are POSIX-complaint without "Bash-isms". Scripts that are Bash-only often are because of the use of arrays.

## `audio_to_opus` (bash)
Simply specify an audio type (e.g. "mp3", "flac") and this script will convert all audio files in that directory to the opus format.

For example, if you execute `bash audio_to_opus flac`: all "\*.flac" files in the working directory will be converted to "\*.opus" files, all "\*.flac" files will be placed into a new "flac/" directory, again in the working directory.

## `aur` (bash)
Miniscule AUR helper.

Four functions:

```
=> [c]heck           - Check local package versions against those on the AUR.
                       Pass --quiet/-q flag to print only non-matching versions.
=> [f]etch [name(s)] - Clone git repository of [name] package(s) on the AUR.
=> [p]kgbuild [name] - Print the PKGBUILD for [name] package
=> [i]nfo [name]     - Show full information for [name] package on the AUR.
=> [s]earch [name]   - Search for [name] on the AUR.
```

Note that though `aur` is licensed under the GPLv3 license, the script incorporates work Copyright (C) 2016-2019 Dylan Araps originally from MIT-licensed code from [pash](https://github.com/dylanaraps/pash). See [Maintaining Permissive-Licensed Files in a GPL-Licensed Project: Guidelines for Developers](https://softwarefreedom.org/resources/2007/gpl-non-gpl-collaboration.html) by the Software Freedom Law Center for more information.

## `check_all.sh`
Checks all shell scripts in the current directory with shellcheck.

## `gather_time_data` (bash)
I no longer recommend using this script. Instead I recommend using `hyperfine`: https://github.com/sharkdp/hyperfine

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
- Check for AUR package updates
  - This functionality requires the `aur` script from this repo to be in your `$PATH`
- Remove unused packages
- Remove journald entries older than 1 day
- Update installed flatpaks and remove unused flatpaks
  - This functionality requires the [flatpak](https://www.archlinux.org/packages/extra/x86_64/flatpak/) package to be installed
- Check your pacman database for errors
- List failed systemd units
- List `*.pacsave` and `*.pacnew` files in `/etc`
- Print disk usage

## `timer.sh`

Requires the `termdown` and `mpv` packages to be installed.

Specify a termdown timer, e.g. `timer.sh 5m`, and this script will play a sound file on repeat when the termdown timer is finished. Specify which sound file to play by setting the `$TIMER_SOUND_FILE` environment variable to a valid sound file path.

## `update_git_repos` (bash)
This script will run `git pull --prune` inside every Git repository in the current directory.

## `update_wow_addons` (bash)
I no longer recommend using this script. Instead I recommend using Cursebreaker: https://github.com/AcidWeb/CurseBreaker

## `watch_add_packages` (bash)
Watches a specified directory (`$DROPBOX_PATH` in your env) for new packages and moves them to a specified pacman repo (`$REPO_ROOT` in your env).

Comes with `watch_add_packages.service`. To add your own enviroment variables to a server environment, first create the override directory:

> `$ sudo mkdir /etc/systemd/system/watch_add_packages.service.d`

Then save an override file (for example `/etc/systemd/system/watch_add_packages.service.d/env-vars.conf`) with the following contents (**change the actual paths to match your own setup**):

```
[Service]
Environment="DROPBOX_PATH=/home/admin/package-dropbox"
Environment="REPO_ROOT=/var/www/builds/x86_64"
```

Finally, reload systemd and restart the service:

> `$ sudo systemctl daemon-reload && sudo systemctl restart watch_add_packages.service`

Now whenever you `rsync` files to the `$DROPBOX_PATH` on the remote, `watch_add_packages` will pick them up and move them to your `$REPO_ROOT`, `chown root:root` them, and add them to the pacman repo package database.