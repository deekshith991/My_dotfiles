#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

# Function to handle errors
error_exit() {
  echo "Error occurred in script at line $1."
  exit 1
}

# Trap the ERR signal to call error_exit on failure
trap 'error_exit $LINENO' ERR

# Function to check if a file exists
check_file() {
  local FILE="$1"
  if [[ ! -f "$FILE" ]]; then
    echo "File $FILE does not exist."
    return 1 # Indicate failure
  fi
  return 0 # Indicate success
}

# Function to restore a directory from a backup zip file
restore_directory() {
  local ZIP_FILE="$1"
  local RESTORE_DIR="$2"

  # Extract the zip file to the restore directory
  unzip -o "$ZIP_FILE" -d "$RESTORE_DIR"
  echo "Restored from: $ZIP_FILE to $RESTORE_DIR"
}

# Main function to handle the restoration process
main() {
  local BACKUP_DIR="$HOME/backup" # Change this if backups are stored elsewhere

  # Check if the backup directory exists
  if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "Backup directory $BACKUP_DIR does not exist."
    exit 1
  fi

  # Find all zip files in the backup directory
  local ZIP_FILES=("$BACKUP_DIR"/*.zip)

  # Check if any zip files were found
  if [[ ${#ZIP_FILES[@]} -eq 0 ]]; then
    echo "No backup zip files found in $BACKUP_DIR."
    exit 1
  fi

  # Restore each zip file
  for ZIP_FILE in "${ZIP_FILES[@]}"; do
    # Determine the original directory from the zip filename
    BASENAME=$(basename "$ZIP_FILE" .zip)
    ORIGINAL_DIR="$HOME/${BASENAME//_//}" # Replace underscores with slashes

    # Create the original directory if it doesn't exist
    mkdir -p "$ORIGINAL_DIR"

    # Restore the directory
    restore_directory "$ZIP_FILE" "$ORIGINAL_DIR"
  done
}

# Execute the main function
main
