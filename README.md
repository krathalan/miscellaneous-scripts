# Krathalan's Scripts
This repository is a collection of scripts I wrote and use/update regularly. These scripts are provided without warranty in the hope that you will find them useful. Contributions are accepted, just open an issue or a pull request.

Please don't run these scripts without reading them first. Always read a script before running it on your machine, especially if it requires sudo/root privileges.

Six POSIX-compliant sh scripts, six Bash scripts. Scripts ending in `.sh` are POSIX-complaint without "Bash-isms". Scripts that are Bash-only often are because of the use of arrays.

## `audio_to_opus` (bash)
Simply specify an audio type (e.g. "mp3", "flac") and this script will convert all audio files in that directory to the opus format. 

For example, if you execute `bash audio_to_opus flac`: all "\*.flac" files in the working directory will be converted to "\*.opus" files, all "\*.flac" files will be placed into a new "flac/" directory, again in the working directory. 

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

## `prntscrn.sh`
Takes a nice screenshot after the specified seconds and saves it to `${XDG_PICTURES_DIR}/screenshots`. Displays a notification when the screenshot is taken. Easily bound to a key in your i3 or sway config. Uses `scrot` for i3/Xorg and `grim` for sway/Wayland. Provides nice errors via desktop notifications as well if you don't have the proper package installed.

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

## `script_template.sh`
A simple POSIX-compliant script template I use. Easy to use as a Bash script template as well.

## `setup_linux.sh`
This script sets up Arch Linux with the programs I use and configures a few things for me automatically. This script is meant to be run *after installation*, NOT as an installation script. You don't want to run this script without reading through it and changing it to your liking. 

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
This script will `git pull` inside every Git repository in `~/git`. The script will automatically determine whatever branch the repository is on and pull that branch. For example, if I had a Git repository at `~/git/miscellaneous-scripts` on the branch "testing", and I ran the `update_git_repos` script, the script would run `git pull origin testing` in the `~/git/miscellaneous-scripts` directory.

This script will skip any directory ending in ".git".

## `update_wow_addons` (bash)
A script that updates all your World of Warcraft addons. You will need to edit some variables at the top of the script to specify your addons and installation location instead of mine.

As of September 29, 2019, due to Cloudflare restrictions, it is impossible to use `wget` or `curl` to download addons from the command line. Therefore the design of the script has changed. The script now opens your default browser, then opens a download link for each addon. Ensure your `~/Downloads` folder is empty of `*.zip` files before starting the script. 

Tip: in Firefox's settings, under General > Files and Applications > Downloads, set Firefox to "Save files do Downloads" automatically so you don't have to click "Save" for each addon.

Click here for a video of the script in action: [https://peertube.social/videos/watch/3e2c4f6d-6d10-450b-997f-5d3b2f2d85fe](https://peertube.social/videos/watch/3e2c4f6d-6d10-450b-997f-5d3b2f2d85fe)

## `update_wow_addons_classic` (bash)
The same as the previous script, but for Classic! You will need to edit some variables to specify your addons and installation location instead of mine.

Note: this script has not been touched in some time and may be broken.
