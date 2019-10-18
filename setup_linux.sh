#!/bin/sh
#
# Description: Installs various packages on Arch Linux.
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
set -eu # (Eo pipefail) is Bash only!

# -----------------------------------------
# ----------- Program variables -----------
# -----------------------------------------

# Colors
readonly GREEN=$(tput bold && tput setaf 2)
readonly RED=$(tput bold && tput setaf 1)
readonly PURPLE=$(tput bold && tput setaf 5)
readonly NC=$(tput sgr0) # No color/turn off all tput attributes

# Step variables
stepCounter=1
stepWithColor="${PURPLE}${stepCounter}${NC}"

# Other
readonly SCRIPT_NAME=$(basename "$0")

# -----------------------------------------
# --------------- Functions ---------------
# -----------------------------------------

#######################################
# Installs the specified package.
# Globals:
#   none
# Arguments:
#   $1: package to install
# Returns:
#   none
#######################################
install_package()
{
	sudo pacman -S --needed --noconfirm "$1"
}

#######################################
# Prints passed error message before premature exit.
# Prints everything to >&2 (STDERR).
# Globals:
#   RED, NC
#   SCRIPT_NAME
# Arguments:
#   $1: error message to print
# Returns:
#   none
#######################################
exit_script_on_failure() 
{
  printf "\n[%s✖%s] Error: %s\n" "${RED}" "${NC}" "$1" >&2
  printf "Exiting %s Bash script.\n" "${SCRIPT_NAME}" >&2

  exit 1
}

#######################################
# Prints "Done."
# Globals:
#   PURPLE, stepCounter, NC
# Arguments:
#   none
# Returns:
#   none
#######################################
print_done() 
{
  stepCounter=$(( stepCounter + 1 ))
  stepWithColor="${PURPLE}${stepCounter}${NC}"
  printf "Done.\n\n"
}

# -----------------------------------------
# ---------------- Script -----------------
# -----------------------------------------

# Print intro
printf "Starting %s sh script; Copyright (C) 2019-%s krathalan\n" "${SCRIPT_NAME}" "$(date +%Y)"
printf "This is free software: you are free to change and redistribute it.\n"
printf "There is NO WARRANTY, to the extent permitted by law.\n\n"

if [ "$(whoami)" = "root" ]; then
  exit_script_on_failure "This script should NOT be run as root (or sudo)!"
fi

printf "%s. Installing fonts with pacman...\n" "${stepWithColor}"
install_package noto-fonts
install_package noto-fonts-cjk
install_package noto-fonts-emoji
install_package ttf-dejavu
install_package ttf-fira-mono
install_package ttf-ibm-plex
install_package ttf-linux-libertine
install_package ttf-roboto
print_done

printf "%s. Installing system packages with pacman...\n" "${stepWithColor}"
install_package alsa-plugins
install_package apparmor
install_package bash-completion
install_package bluez-utils
install_package cups
install_package cups-pdf
install_package dash
install_package dosfstools
install_package e2fsprogs
install_package ffmpeg
install_package gptfdisk
install_package hplip
install_package iftop
install_package intel-ucode
install_package iw
install_package iwd
install_package logrotate
install_package man-db
install_package man-pages
install_package nano
install_package nano-syntax-highlighting
install_package ncdu
install_package ntfs-3g
install_package openvpn
install_package pamixer
install_package pavucontrol
install_package pigz
install_package playerctl
install_package pulseaudio-alsa
install_package reflector
install_package rng-tools
install_package stress
install_package system-config-printer
install_package tmux
install_package tree
install_package unzip
install_package usbutils
install_package wget
install_package which
install_package wireguard-arch
install_package wireguard-tools
install_package zip
print_done

printf "%s. Installing development packages...\n" "${stepWithColor}"
install_package clang
install_package code
install_package lld
install_package meson
install_package ninja
install_package shellcheck
print_done

printf "%s. Installing user packages...\n" "${stepWithColor}"
install_package alacritty
install_package alacritty-terminfo
install_package android-tools
install_package aspell
install_package aspell-en
install_package borg
install_package calc
install_package dictd
install_package evince
install_package firefox
install_package firefox-developer-edition
install_package foliate
install_package gimp
install_package git
install_package gnome-characters
install_package hunspell-en_US
install_package imagemagick
install_package imv
install_package irssi
install_package jq
install_package mediainfo
install_package libreoffice-fresh
install_package lollypop
install_package lynx
install_package mosh
install_package mpv
install_package neofetch
install_package notification-daemon
install_package papirus-icon-theme
install_package pass
install_package perl-image-exiftool
# For mounting a borg backup as a file system
install_package python-llfuse
install_package streamlink
install_package syncthing
install_package thunderbird
install_package transmission-cli
install_package youtube-dl
install_package zim
print_done

printf "%s. Installing gstreamer packages for additional codecs...\n" "${stepWithColor}"
install_package gst-libav
install_package gst-plugins-base
install_package gst-plugins-good
print_done

printf "%s. Installing go to build yay...\n" "${stepWithColor}"
install_package go
print_done

if [ ! -x "$(command -v yay)" ]; then
  printf "%s. Installing yay...\n" "${stepWithColor}"
  aurURL="https://aur.archlinux.org/yay.git"
  tempFolderName="$(mktemp -d --tmpdir=/tmp "setup_linux.sh.XXXXX")"
  printf "==> Cloning %s to a temporary folder...\n" "${aurURL}"
  (
  cd "${tempFolderName}" || exit
  git clone "${aurURL}"
  cd yay || exit
  makepkg -si
  rm -rf "${tempFolderName}"
  )
  print_done
fi

printf "%s. Installing cmake to build pulseaudio-modules-bt-git...\n" "${stepWithColor}"
install_package cmake
print_done

printf "%s. Installing packages from AUR...\n" "${stepWithColor}"
yay -S libldac
yay -S plata-theme
yay -S sparse
yay -S ttf-material-design-icons-webfont
yay -S ttf-roboto-mono
yay -S wtwitch
yay -S yay
# Must be installed *after* libldac
yay -S pulseaudio-modules-bt-git
print_done

# Machine specific configuration
if grep -q desktop /etc/hostname; then
  if ! grep -q GDK_SCALE /etc/environment; then
    printf "%s Enabling 2x DPI scaling for your HiDPI display...\n" "${stepWithColor}"
    printf "GDK_SCALE=2" | sudo tee -a /etc/environment > /dev/null
    print_done
  fi

  printf "%s Installing Xorg packages...\n" "${stepWithColor}"
  install_package compton
  install_package dmenu
  install_package dunst
  install_package feh
  install_package i3-gaps
  install_package i3lock
  install_package i3status
  install_package redshift
  install_package scrot
  # From AUR
  yay -S polybar
  print_done

  if lspci | grep -qi nvidia; then
    printf "%s Installing Nvidia packages...\n" "${stepWithColor}"
    install_package nvidia
    install_package opencl-nvidia
    print_done
  fi
elif grep -q laptop /etc/hostname; then
  printf "%s Installing power management packages...\n" "${stepWithColor}"
  install_package smartmontools
  install_package tlp
  install_package x86_energy_perf_policy
  print_done

  printf "%s Installing Wayland packages...\n" "${stepWithColor}"
  install_package bemenu
  install_package grim
  install_package light
  install_package mako
  install_package sway
  install_package swaylock
  install_package waybar
  install_package wl-clipboard
  # From AUR
  yay -S redshift-wlr-gamma-control
  yay -S wdisplays-git
  print_done

  printf "%s Adding user to \"video\" group for light package...\n" "${stepWithColor}"
  sudo usermod -aG video "${LOGNAME}"
  print_done
fi

# Print summary info for user
printf "[%s✔%s] %s complete.\n" "${GREEN}" "${NC}" "${SCRIPT_NAME}"
