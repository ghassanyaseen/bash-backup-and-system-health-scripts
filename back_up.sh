#!/bin/bash

# Function to prompt user for backup type for each directory
user_choice_directory() {
    while true; do
        echo "Choose backup type for directory '$1':"
        echo "1. Backup the directory without compress"
        echo "2. Compress the directory (tar.gz)"
        echo "3. Compress the directory (tar.xz)"
        echo "4. Compress the directory (7-Zip)"
        read -p "Enter your choice (1/2/3/4): " backupchoice

        case $backupchoice in
            1|2|3|4) break ;;
            *) echo "Invalid choice. Please select a number 1, 2, 3, or 4" ;;
        esac
    done
}

# Function to log messages with the time for every event
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Function to get user-friendly directory name
user_directory() {
    basename "$1"
}

# Function to backup directory
backup_directory() {
    cp -r "$1" "$backupdirectory/$(user_directory "$1")"
    if [ $? -eq 0 ]; then
        log_message "Backup of directory '$1' completed successfully."
        dir_size=$(du -sk "$1" | cut -f1)
        log_message "Backup size of directory '$1': ${dir_size}KB."
        echo "Backup size of directory '$1': ${dir_size}KB."
    else
        log_message "Backup of directory '$1' failed."
    fi
}

# Function to compress directory using tar.gz
compress_directory_tar_gz() {
    # Check if tar command is available
    if ! command -v tar &> /dev/null; then
        log_message "Error: tar command not found. Please install tar."
        echo "Error: tar command not found. Please install tar."
        return 1
    fi

    local dir_name=$(user_directory "$1")
    local backup_file="$backupdirectory/backup_${dir_name}_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$backup_file" -C "$1" . 2>> "$log_file"
    if [ $? -eq 0 ]; then
        log_message "Compression (tar.gz) of directory '$1' completed successfully."
        compressed_size=$(du -sk "$backup_file" | cut -f1)
        log_message "Compressed (tar.gz) size of directory '$1': ${compressed_size}KB."
        echo "Compressed (tar.gz) size of directory '$1': ${compressed_size}KB."
    else
        log_message "Compression (tar.gz) of directory '$1' failed."
    fi
}

# Function to compress directory using tar.xz
compress_directory_tar_xz() {
    # Check if tar command is available
    if ! command -v tar &> /dev/null; then
        log_message "Error: tar command not found. Please install tar."
        echo "Error: tar command not found. Please install tar."
        return 1
    fi

    local dir_name=$(user_directory "$1")
    local backup_file="$backupdirectory/backup_${dir_name}_$(date +%Y%m%d_%H%M%S).tar.xz"
    tar -cJf "$backup_file" -C "$1" . 2>> "$log_file"
    if [ $? -eq 0 ]; then
        log_message "Compression (tar.xz) of directory '$1' completed successfully."
        compressed_size=$(du -sk "$backup_file" | cut -f1)
        log_message "Compressed (tar.xz) size of directory '$1': ${compressed_size}KB."
        echo "Compressed (tar.xz) size of directory '$1': ${compressed_size}KB."
    else
        log_message "Compression (tar.xz) of directory '$1' failed."
    fi
}

# Function to compress directory using 7-Zip
compress_directory_7zip() {
    local dir_name=$(user_directory "$1")
    local backup_file="$backupdirectory/backup_${dir_name}_$(date +%Y%m%d_%H%M%S).7z"
    
    # Check if 7-Zip command is available
    if ! command -v 7z &> /dev/null; then
        log_message "Error: 7-Zip command not found. Please install 7-Zip."
        echo "Error: 7-Zip command not found. Please install 7-Zip."
        return 1
    fi
    
    # Compress directory using 7-Zip
    7z a "$backup_file" "$1" &>> "$log_file"
    if [ $? -eq 0 ]; then
        compressed_size=$(du -sk "$backup_file" | cut -f1)
        log_message "Compression (7-Zip) of directory '$1' completed successfully."
        log_message "Compressed (7-Zip) size of directory '$1': ${compressed_size}KB."
        echo "Compressed (7-Zip) size of directory '$1': ${compressed_size}KB."
    else
        log_message "Compression (7-Zip) of directory '$1' failed."
    fi
}

# Main script execution

log_file="./backup_file.log"
default_backupdirectory="./backup_file"

log_message "Backup started..."

if [ $# -eq 0 ]; then
    while true; do
        read -p "Enter the path of the directory to back up or type 'cancel' to exit: " user_directory
        if [ "$user_directory" == "cancel" ]; then
            echo "Operation cancelled by user."
            log_message "Backup operation cancelled by user."
            exit 0
        elif [ -d "$user_directory" ]; then
            set -- "$user_directory"
            break
        else
            echo "Invalid directory. Please enter a valid directory."
        fi
    done
fi

while true; do
    read -p "Enter the path where you want to save the backup (press Enter to use the default backup directory): " user_backup_dir
    if [ -z "$user_backup_dir" ]; then
        user_backup_dir="$default_backupdirectory"
        mkdir -p "$user_backup_dir"
        log_message "No directory specified. Using default backup directory: '$user_backup_dir'."
        echo "No directory specified. Using default backup directory: '$user_backup_dir'."
        break
    elif [ -d "$user_backup_dir" ] || mkdir -p "$user_backup_dir"; then
        backupdirectory="$user_backup_dir"
        log_message "Backup directory set to '$backupdirectory'."
        break
    else
        echo "Invalid directory. Please enter a valid directory."
    fi
done

backupdirectory="$user_backup_dir"
for dir in "$@"; do
    if [ -d "$dir" ]; then
        real_dir=$(realpath "$dir")
        log_message "Processing directory '$dir'."

        user_choice_directory "$dir"
        log_message "User chose option '$backupchoice' for directory '$dir'."

        echo "----------------------- Start -----------------------"

        case $backupchoice in
            1) backup_directory "$dir" ;;
            2) compress_directory_tar_gz "$dir" ;;
            3) compress_directory_tar_xz "$dir" ;;
            4) compress_directory_7zip "$dir" ;;
        esac

        echo "-----------------------  End  -----------------------"
    else
        log_message "Error: '$dir' is not a valid directory."
        echo "Error: '$dir' is not a valid directory."
    fi
done

log_message "Backup process completed."
echo "Process completed. You can check the $log_file for more details."
