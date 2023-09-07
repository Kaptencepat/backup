#!/bin/bash

# Konfigurasi koneksi ke database
BACKUP_DIR=/home/adam-user/backup/
current_date=$(date +%Y-%m-%d) 
two_days_ago=$(date -d "$current_date -2 days" +%Y-%m-%d)
zip_filename=namaRS-$current_date.zip
zip_file=backup-$current_date.zip

docker exec -t db-transaksi-lis pg_dump -c -U postgres -d transaksi > $BACKUP_DIR/transaksi_$current_date.sql
docker exec -t db-datamaster-lis pg_dump -c -U postgres -d datamaster > $BACKUP_DIR/datamaster_$current_date.sql
docker exec -t db-archive-lis pg_dump -c -U postgres -d arsip > $BACKUP_DIR/archive_$current_date.sql
docker exec -t db-pasien-lis pg_dump -c -U postgres -d pasien > $BACKUP_DIR/pasien_$current_date.sql
docker exec -t db-recyclebin-lis pg_dump -c -U postgres -d recyclebin > $BACKUP_DIR/recyclebin_$current_date.sql

cd $BACKUP_DIR
zip -r "$zip_filename" transaksi_$current_date.sql  datamaster_$current_date.sql archive_$current_date.sql pasien_$current_date.sql recyclebin_$current_date.sql
sshpass -p 'resman56adam' scp -r "$zip_filename" adam-user@10.8.0.6:/home/adam-user/BackupALL/"$zip_file"

rm transaksi_$current_date.sql  datamaster_$current_date.sql archive_$current_date.sql pasien_$current_date.sql recyclebin_$current_date.sql

# find "$BACKUP_DIR" -name "backup-*.zip" -type f -ctime +2 -exec rm {} \;

current_timestamp=$(date +%s)

# Menghitung timestamp 2 hari yang lalu
two_days_ago_timestamp=$((current_timestamp - 2 * 24 * 60 * 60))

# Menggunakan 'find' untuk mencari file ZIP lebih tua dari 2 hari
# dan menghapusnya dengan 'rm'
find "$BACKUP_DIR" -name "backup-*.zip" -type f -exec stat -c "%Y %n" {} \; | while read filedate filename
do
  if [ "$filedate" -lt "$two_days_ago_timestamp" ]; then
    rm "$filename"
    echo "File $filename dihapus."
  fi
done
