
# Ubuntu Setup Script

## Overview
This script automates the installation of essential packages on an Ubuntu system. It updates package lists, installs APT packages, installs the Brave browser, checks for Nix installation, and installs specified Nix packages. It also installs Create React App globally.

## Features
- Updates APT package lists.
- Installs essential APT packages.
- Installs Brave Browser.
- Checks if Nix is installed and lists installed Nix packages.
- Installs specified Nix packages.
- Installs Create React App globally.
- Logs all actions to `setup.log`.

## APT Packages
The script installs the following APT packages:
- curl
- stow
- git
- nodejs
- npm
- direnv
- bat
- zoxide
- gcc
- g++
- default-jdk
- default-jre
- python3
- ubuntu-restricted-extras

## Nix Packages
If Nix is installed, the script installs the following Nix packages:
- fzf
- age
- portal
- atac

## Requirements
- Ubuntu system
- `sudo` privileges
- Nix package manager (optional)

## Usage
1. **Clone the repository:**
   ``` bash
   git clone https://github.com/deekshith991/My_dotfiles
   cd My_dotfiles
   stow folder1 folder2 ....
   ```


