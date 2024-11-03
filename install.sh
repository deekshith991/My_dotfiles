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
  echo # Add an empty line for better readability
  if [[ "$confirm" != "y" ]]; then
    log "APT package installation aborted."
    exit 0
  fi

  log "You may be prompted to enter your password for sudo access."

  for pkg in "${packages[@]}"; do
    if dpkg -l | grep -q "$pkg"; then
      log "\033[1;33m$pkg is already installed.\033[0m"
    else
      echo # Empty line before installation message
      log "Installing \033[1;32m$pkg\033[0m..."
      sudo apt install -y "$pkg" || log "Failed to install \033[1;31m$pkg\033[0m."
      echo -e "\n\033[1;32m$pkg installed successfully!\033[0m\n" # Success message
    fi
  done
}

# Function to install Brave Browser
install_brave() {
  log "Preparing to install Brave Browser..."
  read -p "Do you want to proceed with the installation of Brave Browser? (y/n): " confirm_brave
  echo # Add an empty line for better readability
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
    echo # Empty line before installation message
    log "Installing \033[1;32mBrave Browser\033[0m..."
    sudo apt install -y brave-browser || log "Failed to install Brave Browser."
    echo -e "\n\033[1;32mBrave Browser installed successfully!\033[0m\n" # Success message
  fi
}

# Function to install Bruno
install_bruno() {
  log "Preparing to install Bruno from the custom repository..."
  read -p "Do you want to proceed with the installation of Bruno? (y/n): " confirm_bruno
  echo # Add an empty line for better readability
  if [[ "$confirm_bruno" != "y" ]]; then
    log "Bruno installation aborted."
    return
  fi

  log "Installing dirmngr to manage GPG key connections..."
  sudo apt install -y dirmngr # Ensure dirmngr is installed

  log "Creating directory for APT keyrings..."
  sudo mkdir -p /etc/apt/keyrings

  log "Downloading and adding Bruno GPG key..."
  sudo gpg --no-default-keyring --keyring /etc/apt/keyrings/bruno.gpg --keyserver keyserver.ubuntu.com --recv-keys 56333D3B745C1FEC # Correct key

  log "Adding Bruno repository to sources list..."
  echo "deb [signed-by=/etc/apt/keyrings/bruno.gpg] http://debian.usebruno.com/ bruno stable" | sudo tee /etc/apt/sources.list.d/bruno.list

  log "Updating package lists..."
  sudo apt update

  if dpkg -l | grep -q "bruno"; then
    log "Bruno is already installed."
  else
    echo # Empty line before installation message
    log "Installing \033[1;32mBruno\033[0m..."
    sudo apt install -y bruno || log "Failed to install Bruno."
    echo -e "\n\033[1;32mBruno installed successfully!\033[0m\n" # Success message
  fi
}

# Function to check if Nix is installed
check_nix() {
  command -v nix-env &>/dev/null
}

# Function to list installed Nix packages
list_installed_nix_packages() {
  log "Currently installed Nix packages:"
  nix-env -q | while read pkg; do
    echo -e "    - \033[1;32m$pkg\033[0m"
  done
}

# Function to install Nix packages
install_nix_packages() {
  local packages=("$@")

  log "The following Nix packages will be installed:"
  for pkg in "${packages[@]}"; do
    echo -e "    - \033[1;32m$pkg\033[0m"
  done

  read -p "Do you want to proceed with the installation of Nix packages? (y/n): " confirm_nix
  echo # Add an empty line for better readability
  if [[ "$confirm_nix" != "y" ]]; then
    log "Nix package installation aborted."
    return
  fi

  log "Installing Nix packages..."
  for pkg in "${packages[@]}"; do
    if nix-env -q | grep -q "$pkg"; then
      log "\033[1;33m$pkg is already installed.\033[0m"
    else
      echo # Empty line before installation message
      log "Installing \033[1;32m$pkg\033[0m..."
      nix-env -iA nixpkgs."$pkg" || log "Failed to install \033[1;31m$pkg\033[0m."
      echo -e "\n\033[1;32m$pkg installed successfully!\033[0m\n" # Success message
    fi
  done
}

# Function to install Create React App
install_create_react_app() {
  log "Installing Create React App globally..."
  if npm list -g --depth=0 | grep -q create-react-app; then
    log "Create React App is already installed."
  else
    echo # Empty line before installation message
    log "Installing \033[1;32mCreate React App\033[0m..."
    sudo npm -g install create-react-app || log "Failed to install Create React App."
    echo -e "\n\033[1;32mCreate React App installed successfully!\033[0m\n" # Success message
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
  kdeconnect
)

install_apt_packages "${apt_packages[@]}"
install_brave
# install_bruno

if check_nix; then
  log "Nix is installed. Currently installed Nix packages will be listed:"
  list_installed_nix_packages

  echo # Empty line for better readability
  log "Proceeding to install additional Nix packages..."

  # Define Nix packages
  nix_packages=(
    fzf
    age
    portal
    atac
  )

  install_nix_packages "${nix_packages[@]}"
else
  log "Nix is not installed. Please install Nix manually to proceed with Nix package installations."
fi

install_create_react_app

log "Setup completed successfully!"
