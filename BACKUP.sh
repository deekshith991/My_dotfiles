#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

# Function to handle errors
error_exit() {
  echo "Error occurred in script at line $1."
  exit 1
}

# Trap the ERR signal to call error_exit on failure
trap 'error_exit $LINENO' ERR

# Function to check if a directory exists
check_directory() {
  local DIR="$1"
  if [[ ! -d "$DIR" ]]; then
    echo "Directory $DIR does not exist."
    return 1 # Indicate failure
  fi
  return 0 # Indicate success
}

# Function to backup a directory
backup_directory() {
  local DIR="$1"
  local BACKUP_DIR="$2"

  SIZE=$(du -sb "$DIR" | cut -f1) # Size in bytes
  if ((SIZE < 1073741824)); then  # Less than 1 GB
    BASENAME=$(basename "$DIR")
    ZIP_NAME="$BACKUP_DIR/${BASENAME}_$(realpath --relative-to="$HOME" "$DIR").zip"
    zip -r "$ZIP_NAME" "$DIR"
    echo "Backup created: $ZIP_NAME"
  else
    echo "Directory $DIR is larger than or equal to 1 GB. Checking subdirectories..."
    sort_and_zip_subdirs "$DIR" "$BACKUP_DIR"
  fi
}

# Function to sort and zip subdirectories
sort_and_zip_subdirs() {
  local PARENT_DIR="$1"
  local BACKUP_DIR="$2"
  local SUBDIR_INFO=()

  for SUBDIR in "$PARENT_DIR"/*; do
    if [[ -d "$SUBDIR" ]]; then
      SUBDIR_SIZE=$(du -sb "$SUBDIR" | cut -f1)
      SUBDIR_INFO+=("$SUBDIR_SIZE $SUBDIR")
    fi
  done

  # Sort subdirectories by size
  IFS=$'\n' sorted_subdirs=($(sort -n <<<"${SUBDIR_INFO[*]}"))
  unset IFS

  # Prepare to zip subdirectories in multiples
  local current_zip_size=0
  local zip_name="$BACKUP_DIR/$(basename "$PARENT_DIR")_multiple.zip"
  local zip_dir_list=()

  for entry in "${sorted_subdirs[@]}"; do
    SIZE=$(echo "$entry" | awk '{print $1}')
    SUBDIR=$(echo "$entry" | awk '{print $2}')

    if ((current_zip_size + SIZE < 1073741824)); then # Less than 1 GB
      current_zip_size=$((current_zip_size + SIZE))
      zip_dir_list+=("$SUBDIR")
    else
      # Create zip for the collected directories
      zip -r "$zip_name" "${zip_dir_list[@]}"
      echo "Backup created: $zip_name"

      # Reset for next zip
      current_zip_size=$SIZE
      zip_dir_list=("$SUBDIR")
      zip_name="$BACKUP_DIR/$(basename "$PARENT_DIR")_multiple.zip"
    fi
  done

  # Zip any remaining directories
  if [[ ${#zip_dir_list[@]} -gt 0 ]]; then
    zip -r "$zip_name" "${zip_dir_list[@]}"
    echo "Backup created: $zip_name"
  fi
}

# Main function to handle the backup process
main() {
  local BACKUP_DIR="$HOME/backup"

  # Use command-line arguments for directories, default if none provided
  local DIRS=("$@")
  if [[ ${#DIRS[@]} -eq 0 ]]; then
    DIRS=("$HOME/d1" "$HOME/d2" "$HOME/d3") # Default directories
  fi

  mkdir -p "$BACKUP_DIR"

  for DIR in "${DIRS[@]}"; do
    if check_directory "$DIR"; then
      backup_directory "$DIR" "$BACKUP_DIR"
    fi
  done
}

# Execute the main function with provided arguments
main "$@"
