BEFORE INSTALLATION
-------------------------
----- Back up files -----
-------------------------

backup -g krath -t /media/veracrypt1/Personal_Data -n

AFTER INSTALLATION
---------------------------
----- Install drivers -----
---------------------------

Install Wifi and graphics drivers
- Ubuntu
    - Enable in Software & Updates --> Additional Drivers
    - Reboot
- Fedora
    - sudo bash setup_fedora_drivers
    - Reboot

----------------------------------------------------
----- Perform terminal-available configuration -----
----------------------------------------------------

sudo bash setup_fedora_software
bash configure_services
sudo reboot

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
- Set default text to Linux Libertine
- Change icon pack to Papirus-dark

OpenVPN
- Go to https://nordvpn.com/servers and download the recommended server OpenVPN UDP configuration file
- Open system settings, import file, login, and enable VPN connection
- Verify it's working by visiting https://dnsleaktest.com/ and clicking on extended test

Syncthing:
- Copy /home/anders/.config/syncthing from extracted archive in ~/Downloads to /home/anders/.config
- Setup autostart: https://docs.syncthing.net/users/autostart.html

Thunderbird:
- Copy /home/anders/.thunderbird from extracted archive in ~/Downloads to /home/anders

VS Codium settings:
{
    "editor.cursorSmoothCaretAnimation": true,
    "editor.fontFamily": "'Roboto Mono'",
    "editor.fontSize": 14,
    "editor.smoothScrolling": true,
    "files.autoSave": "afterDelay",
    "telemetry.enableCrashReporter": false,
    "telemetry.enableTelemetry": false,
    "update.channel": "none",
    "update.enableWindowsBackgroundUpdates": false,
    "update.showReleaseNotes": false,
    "window.titleBarStyle": "custom",
    "window.restoreWindows": "none",
    "workbench.enableExperiments": false,
    "workbench.settings.enableNaturalLanguageSearch": false,
    "workbench.startupEditor": "none",
    "files.autoSaveDelay": 750,
    "workbench.colorTheme": "Material Basic - Materia Contrast",
    "workbench.iconTheme": "material-icon-theme",
}

Ensure $PATH and secure_path are configured correctly.

Reboot.