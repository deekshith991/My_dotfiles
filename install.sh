#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Log file
LOGFILE="setup.log"

# Function to log messages
log() {
  echo -e "\033[1;34m$(date '+%Y-%m-%d %H:%M:%S') - $1\033[0m" | tee -a "$LOGFILE"
}

# Function to update package lists
update_apt() {
  log "Updating package lists..."
  sudo apt update
}

# Function to install APT packages
install_apt_packages() {
  local packages=("$@")
  log "The following APT packages will be installed:"
  for pkg in "${packages[@]}"; do
    echo -e "    - \033[1;32m$pkg\033[0m"
  done

  read -p "Do you want to proceed with the installation of APT packages? (y/n): " confirm
  if [[ "$confirm" != "y" ]]; then
    log "APT package installation aborted."
    exit 0
  fi

  log "You may be prompted to enter your password for sudo access."

  for pkg in "${packages[@]}"; do
    if dpkg -l | grep -q "$pkg"; then
      log "\033[1;33m$pkg is already installed.\033[0m"
    else
      log "Installing \033[1;32m$pkg\033[0m..."
      sudo apt install -y "$pkg" || log "Failed to install \033[1;31m$pkg\033[0m."
    fi
  done
}

# Function to install Brave Browser
install_brave() {
  log "Preparing to install Brave Browser..."
  read -p "Do you want to proceed with the installation of Brave Browser? (y/n): " confirm_brave
  if [[ "$confirm_brave" != "y" ]]; then
    log "Brave Browser installation aborted."
    return
  fi

  keyring_path="/usr/share/keyrings/brave-browser-archive-keyring.gpg"

  if [ -f "$keyring_path" ]; then
    log "Brave browser keyring already exists."
  else
    log "Downloading Brave browser keyring..."
    sudo curl -fsSLo "$keyring_path" https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    log "Adding Brave browser repository..."
    echo "deb [signed-by=$keyring_path] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update
  fi

  if dpkg -l | grep -q "brave-browser"; then
    log "Brave Browser is already installed."
  else
    log "Installing Brave Browser..."
    sudo apt install -y brave-browser || log "Failed to install Brave Browser."
  fi
}

# Function to check if Nix is installed
check_nix() {
  command -v nix-env &>/dev/null
}

# Function to install Nix packages
install_nix_packages() {
  local packages=("$@")

  log "The following Nix packages will be installed:"
  for pkg in "${packages[@]}"; do
    echo -e "    - \033[1;32m$pkg\033[0m"
  done

  read -p "Do you want to proceed with the installation of Nix packages? (y/n): " confirm_nix
  if [[ "$confirm_nix" != "y" ]]; then
    log "Nix package installation aborted."
    return
  fi

  log "Installing Nix packages..."
  for pkg in "${packages[@]}"; do
    if nix-env -q | grep -q "$pkg"; then
      log "\033[1;33m$pkg is already installed.\033[0m"
    else
      log "Installing \033[1;32m$pkg\033[0m..."
      nix-env -iA nixpkgs."$pkg" || log "Failed to install \033[1;31m$pkg\033[0m."
    fi
  done
}

# Function to install Create React App
install_create_react_app() {
  log "Installing Create React App globally..."
  if npm list -g --depth=0 | grep -q create-react-app; then
    log "Create React App is already installed."
  else
    sudo npm -g install create-react-app || log "Failed to install Create React App."
  fi
}

# Main script execution
update_apt

# Define APT packages (tmux and lazygit removed)
apt_packages=(
  curl
  stow
  git
  nodejs
  npm
  direnv
  bat
  zoxide
  gcc
  g++
  default-jdk
  default-jre
  python3
  ubuntu-restricted-extras
)

install_apt_packages "${apt_packages[@]}"
install_brave

if check_nix; then
  log "Nix is installed. Proceeding to install Nix packages..."

  # Define Nix packages
  nix_packages=(
    fzf
    age
    portal
  )

  install_nix_packages "${nix_packages[@]}"
else
  log "Nix is not installed. Please install Nix manually to proceed with Nix package installations."
fi

install_create_react_app

log "Setup completed successfully!"
