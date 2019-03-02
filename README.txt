BEFORE INSTALLATION
-------------------------
----- Back up files -----
-------------------------

backup -g krath -t /media/veracrypt1/Personal_Data -n

AFTER INSTALLATION
---------------------------
----- Install drivers -----
---------------------------

- Ubuntu
    - Enable in Software & Updates --> Additional Drivers
    - Reboot
- Fedora
    - RPMFusion
        - Enable: sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        - Broadcom Wireless: sudo dnf install broadcom-wl
        - Nvidia Graphics: sudo dnf install xorg-x11-drv-nvidia akmod-nvidia
        - Then update: sudo dnf upgrade --refresh
    - Reboot

----------------------------------------------------
----- Perform terminal-available configuration -----
----------------------------------------------------

- sudo bash setup_fedora_software
- Reboot

-----------------------------
----- Install VeraCrypt -----
-----------------------------

bash install_veracrypt

------------------------------------
----- Restoration instructions -----
------------------------------------

GPG: 
- Import keys from Keepass database
- (Kleopatra) Self-sign keys as yours

Data:
- Copy archive_MM-DD-YYYY.tar.gpg from Backup/Personal_Data to ~/Downloads
- Restore .gitconfig, .bashrc, and ~/.config/syncthing files

Discord:
- Login

Firefox:
- Edit user.js file from archive in ~/Downloads and copy to ~/.mozilla/firefox/profile.default
- Install add-ons (CanvasBlocker, Decentraleyes, HTTPS Everywhere, Privacy Possum, Redirect AMP to HTML, Request Control, uBO, uMatrix)
    - Add uBO lists from firefox-tweaks
    - Import Request Control rules
    - Import uMatrix rules
- Sign in to Firefox sync
- Set DDG as default search engine and remove others

LibreOffice:
- Set default text to Linux Libertine O
- Change icon pack to Papirus-dark

OpenVPN
- Go to https://nordvpn.com/servers and download the recommended server OpenVPN UDP configuration file
- Open system settings, import file, login, and enable VPN connection
- Verify it's working by visiting https://dnsleaktest.com/ and clicking on extended test

Syncthing:
- Set up syncthing as a systemd service: https://docs.syncthing.net/users/autostart.html

Evolution:
- Restore backup

VS Codium settings:
{
    "editor.cursorSmoothCaretAnimation": true,
    "editor.fontFamily": "'Roboto Mono'",
    "editor.fontSize": 14,
    "editor.smoothScrolling": true,
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 750,
    "telemetry.enableCrashReporter": false,
    "telemetry.enableTelemetry": false,
    "update.channel": "none",
    "update.enableWindowsBackgroundUpdates": false,
    "update.showReleaseNotes": false,
    "window.restoreWindows": "none",
    "window.titleBarStyle": "custom",
    "workbench.colorTheme": "Material Basic - Materia Contrast",
    "workbench.enableExperiments": false,
    "workbench.iconTheme": "material-icon-theme",
    "workbench.settings.enableNaturalLanguageSearch": false,
    "workbench.startupEditor": "none",
}

Ensure $PATH and secure_path are configured correctly.

Reboot.