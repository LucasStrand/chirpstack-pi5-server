#!/bin/bash

# ChirpStack Backup and Restore Script
# Handles backup and restoration of ChirpStack data

set -e

BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

show_menu() {
    echo "========================================="
    echo "ChirpStack Backup & Restore Utility"
    echo "========================================="
    echo "1) Create Backup"
    echo "2) Restore from Backup"
    echo "3) List Available Backups"
    echo "4) Delete Old Backups"
    echo "5) Exit"
    echo ""
    read -p "Select an option (1-5): " choice
}

create_backup() {
    echo "Creating backup..."
    
    # Create backup directory if it doesn't exist
    mkdir -p $BACKUP_DIR
    
    # Stop services to ensure data consistency
    echo "Stopping ChirpStack services..."
    docker-compose down
    
    # Create backup archive
    BACKUP_FILE="$BACKUP_DIR/chirpstack_backup_$TIMESTAMP.tar.gz"
    echo "Creating backup archive: $BACKUP_FILE"
    
    tar -czf $BACKUP_FILE \
        data/ \
        config/ \
        docker-compose.yml \
        .env 2>/dev/null || true
    
    # Get backup size
    BACKUP_SIZE=$(du -h $BACKUP_FILE | cut -f1)
    
    # Restart services
    echo "Restarting ChirpStack services..."
    docker-compose up -d
    
    echo ""
    echo "Backup completed successfully!"
    echo "Backup file: $BACKUP_FILE"
    echo "Backup size: $BACKUP_SIZE"
    echo ""
    echo "To copy this backup to another location:"
    echo "scp $BACKUP_FILE user@remote-host:/path/to/destination/"
}

restore_backup() {
    # List available backups
    echo "Available backups:"
    echo ""
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR/*.tar.gz 2>/dev/null)" ]; then
        echo "No backups found in $BACKUP_DIR/"
        return
    fi
    
    # Create array of backup files
    BACKUPS=($BACKUP_DIR/*.tar.gz)
    
    # Display backups with numbers
    for i in "${!BACKUPS[@]}"; do
        BACKUP_NAME=$(basename "${BACKUPS[$i]}")
        BACKUP_SIZE=$(du -h "${BACKUPS[$i]}" | cut -f1)
        echo "$((i+1))) $BACKUP_NAME (Size: $BACKUP_SIZE)"
    done
    
    echo ""
    read -p "Select backup to restore (number): " selection
    
    # Validate selection
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#BACKUPS[@]}" ]; then
        echo "Invalid selection"
        return
    fi
    
    SELECTED_BACKUP="${BACKUPS[$((selection-1))]}"
    echo ""
    echo "Selected backup: $(basename $SELECTED_BACKUP)"
    
    # Confirmation
    echo ""
    echo "WARNING: This will replace all current ChirpStack data!"
    read -p "Are you sure you want to restore this backup? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        echo "Restore cancelled"
        return
    fi
    
    # Stop services
    echo "Stopping ChirpStack services..."
    docker-compose down
    
    # Backup current data (just in case)
    if [ -d "data" ]; then
        echo "Creating safety backup of current data..."
        mv data data_old_$TIMESTAMP
    fi
    if [ -d "config" ]; then
        mv config config_old_$TIMESTAMP
    fi
    
    # Extract backup
    echo "Extracting backup..."
    tar -xzf $SELECTED_BACKUP
    
    # Restore permissions
    chmod -R 755 config data
    
    # Start services
    echo "Starting ChirpStack services..."
    docker-compose up -d
    
    echo ""
    echo "Restore completed successfully!"
    echo "Services are starting up. Check status with: docker-compose ps"
}

list_backups() {
    echo "Available backups:"
    echo ""
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR/*.tar.gz 2>/dev/null)" ]; then
        echo "No backups found in $BACKUP_DIR/"
        return
    fi
    
    # List backups with details
    for backup in $BACKUP_DIR/*.tar.gz; do
        BACKUP_NAME=$(basename "$backup")
        BACKUP_SIZE=$(du -h "$backup" | cut -f1)
        BACKUP_DATE=$(stat -c %y "$backup" | cut -d' ' -f1)
        echo "- $BACKUP_NAME"
        echo "  Size: $BACKUP_SIZE"
        echo "  Date: $BACKUP_DATE"
        echo ""
    done
}

delete_old_backups() {
    echo "Delete old backups"
    echo ""
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR/*.tar.gz 2>/dev/null)" ]; then
        echo "No backups found in $BACKUP_DIR/"
        return
    fi
    
    read -p "Keep how many recent backups? (default: 5): " keep_count
    keep_count=${keep_count:-5}
    
    # Validate input
    if [[ ! "$keep_count" =~ ^[0-9]+$ ]]; then
        echo "Invalid number"
        return
    fi
    
    # Count total backups
    total_backups=$(ls -1 $BACKUP_DIR/*.tar.gz 2>/dev/null | wc -l)
    
    if [ "$total_backups" -le "$keep_count" ]; then
        echo "Currently have $total_backups backups, which is not more than $keep_count"
        echo "No backups deleted"
        return
    fi
    
    # Delete old backups
    delete_count=$((total_backups - keep_count))
    echo "Deleting $delete_count old backup(s)..."
    
    ls -t $BACKUP_DIR/*.tar.gz | tail -n $delete_count | xargs rm -v
    
    echo ""
    echo "Cleanup completed"
}

# Main loop
while true; do
    show_menu
    
    case $choice in
        1)
            create_backup
            ;;
        2)
            restore_backup
            ;;
        3)
            list_backups
            ;;
        4)
            delete_old_backups
            ;;
        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
    clear
done 