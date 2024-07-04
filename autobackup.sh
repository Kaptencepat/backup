#!/bin/bash

# Konfigurasi koneksi ke database
BACKUP_DIR=/home/adam-user/backup/
current_date=$(date +%Y-%m-%d) 
two_days_ago=$(date -d "$current_date -2 days" +%Y-%m-%d)
namaRS="RSBhaktiHusadaRembang"
zip_filename="$namaRS-$current_date.zip"
zip_file="backup-$current_date.zip"

# Backup each database
docker exec -t db-transaksi-lis pg_dump -c -U postgres -d transaksi > "$BACKUP_DIR/transaksi_$current_date.sql"
docker exec -t db-datamaster-lis pg_dump -c -U postgres -d datamaster > "$BACKUP_DIR/datamaster_$current_date.sql"
docker exec -t db-archive-lis pg_dump -c -U postgres -d arsip > "$BACKUP_DIR/archive_$current_date.sql"
docker exec -t db-pasien-lis pg_dump -c -U postgres -d pasien > "$BACKUP_DIR/pasien_$current_date.sql"
docker exec -t db-recyclebin-lis pg_dump -c -U postgres -d recyclebin > "$BACKUP_DIR/recyclebin_$current_date.sql"

# Change to the backup directory
cd "$BACKUP_DIR"

# Compress the SQL files into a ZIP archive
zip -r "$zip_filename" transaksi_$current_date.sql datamaster_$current_date.sql archive_$current_date.sql pasien_$current_date.sql recyclebin_$current_date.sql

# Transfer the ZIP archive to the remote server
sshpass -p 'resman56adam' scp -r "$zip_filename" adam-user@10.8.0.6:/home/adam-user/BackupALL/"$zip_file"

# Remove the SQL files after compression
rm transaksi_$current_date.sql datamaster_$current_date.sql archive_$current_date.sql pasien_$current_date.sql recyclebin_$current_date.sql

# Find and delete backup ZIP files older than 2 days
find "$BACKUP_DIR" -name "$namaRS-*.zip" -type f -mtime +2 -exec rm {} \;

echo "Backup and cleanup completed successfully."
