# Krathalan's Scripts
This repository is a collection of scripts I wrote and use/update regularly. These scripts are provided without warranty in the hope that you will find them useful. Contributions are accepted, just open an issue or a pull request.

Please don't run these scripts without reading them first. Always read a script before running it on your machine, especially if it requires sudo/root privileges (like `ksm`).

Eight POSIX-compliant sh scripts, seven Bash scripts. Scripts that are Bash-only often are because of the use of arrays.

## `audio_to_opus` (bash)
Simply specify an audio type (e.g. "mp3", "flac") and this script will convert all audio files in the current directory of that type to the opus format.

For example, if you execute `bash audio_to_opus flac`: all "\*.flac" files in the working directory will be converted to "\*.opus" files, all "\*.flac" files will be placed into a new "flac/" directory, again in the working directory.

## `cias` (sh)
Runs a Command In All Subdirs (CIAS). For example, running

```
  $ cias git fetch --prune
```

In `~/git` would run `git fetch --prune` in `~/git/*`.

## `compress_cp` (bash)
Compresses and copies a directory in one step.

## `kaur` (bash)
Miniscule AUR helper.

Five commands:

```
=> [c]heck           - Check local package versions against those on the AUR.
                       Pass --quiet/-q flag to print only non-matching versions.
=> [f]etch [name(s)] - Clone git repository of [name] package(s) on the AUR.
=> [p]kgbuild [name] - Print the PKGBUILD for [name] package
=> [i]nfo [name]     - Show full information for [name] package on the AUR.
=> [s]earch [name]   - Search for [name] on the AUR.
```

Note that though `kaur` is licensed under the GPLv3 license, the script incorporates work Copyright (C) 2016-2019 Dylan Araps originally from MIT-licensed code from [pash](https://github.com/dylanaraps/pash). See [Maintaining Permissive-Licensed Files in a GPL-Licensed Project: Guidelines for Developers](https://softwarefreedom.org/resources/2007/gpl-non-gpl-collaboration.html) by the Software Freedom Law Center for more information.

## `kps` (sh)
Takes a nice screenshot after the specified seconds and saves it to `${XDG_PICTURES_DIR}/screenshots`. Displays a notification when the screenshot is taken. Easily bound to a key in your i3 or sway config. Uses `scrot` for i3/Xorg and `grim` for sway/Wayland. Provides nice errors via desktop notifications as well if you don't have the proper package installed.

On sway/Wayland, invoking `kps` with any argument, like `kps slurp`, will allow you to select an area of the screen and will copy the selected area to your clipboard as a jpeg.

## `ksm` (sh)
This script will perform system maintenance on an Arch Linux system. It will:

- Clean pacman caches (if the flag `--clean` is passed)
- Update installed packages
- Remove unused packages
- Remove journald entries older than 3 days
- Update installed flatpaks
  - This functionality requires the [flatpak](https://www.archlinux.org/packages/extra/x86_64/flatpak/) package to be installed
- Check your pacman database for errors
- List failed systemd units
- List `*.pacsave` and `*.pacnew` files in `/etc`
- Check AppArmor profile versions (if `krathalans-apparmor-profiles` installed)
- Print root disk usage

## `list_nonfree_packages` (bash)
Lists nonfree packages installed on Arch Linux according to Parabola's blacklist. Ignores packages that are blacklisted for "branding" or "technical" reasons; that is, they are not necessarily nonfree, but may conflict with Parabola's rebuilds of certain packages.

## `make_gif` (sh)
I made this script after the camera app I use on my phone lost its auto-gif-making functionality whenever I would take burst photos.

To use it, put the photos you want to make into a gif into a directory, and then run the script in that directory.

Here's an example gif of my cat I made with make_gif:

![Example](https://i.imgur.com/V63J3UY.gif)

## mythic_event (bash)
A script I made for my World of Warcraft guild's Mythic+ dungeon event. Supply a list of characters with their realm, like so:

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
  | https://github.com/krathalan/miscellaneous-scripts |
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

## `scramble_photos` (sh)
Deletes the exif data on all photos in the current directory and attempts to restore the "datetimeoriginal" (date taken) value from the photo's file name. Then moves them to `${HOME}/pictures/$(date +%Y)`, e.g. `~/pictures/2020`; creating the folder if it doesn't exist. Pass `--no-copy` to keep them in the current directory.

## `script_template.sh`
A simple POSIX-compliant script template I use. Easy to use as a Bash script template as well.

## `shellcheck_all` (sh)
Checks all shell scripts in the current directory with shellcheck.

## `test-compression` (bash)
Tests a ton of compression algorithms at various compression levels on a specified folder and outputs data including final file sizes, compression ratios, elapsed time to compress, elapsed time to decompress, and recommends the best compression setting for a given use case.

Tests the following algorithms and levels, though more can be added easily:

```
  "lzop -1" "lzop -3"
  "xz -3" "xz -6" "xz -9"
  "pigz -3" "pigz -6" "pigz -9"
  "lz4 -1" "lz4 -3" "lz4 -5" "lz4 -9"
  "brotli -1" "brotli -3" "brotli -5" "brotli -7" "brotli -9"
  "pzstd -10" "pzstd -12" "pzstd -15" "pzstd -17" "pzstd -19"
```

## `timer.sh`
Requires the `termdown` and `mpv` packages to be installed.

Specify a termdown timer, e.g. `timer.sh 5m`, and this script will play a sound file on repeat when the termdown timer is finished. Specify which sound file to play by setting the `$TIMER_SOUND_FILE` environment variable to a valid sound file path.
