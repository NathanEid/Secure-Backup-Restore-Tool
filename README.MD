# Secure Backup/Restore

## Tool Overview:
The goal of this Tool is to write 2 bash scripts that perform secure encrypted backup and restore functionality. You should be able to maneuver through the Linux configuration files and be able to schedule running the backup script on predefined times. Finally, you will need to copy the backup to a remote server.

## Used Tools and COmmands:
- Bash Script
- tar
- gnupg
- scp

## Note:
Before running the script, ensure that the required dependencies are installed on your system, such as "gpg" and "tar". Also, ensure that you have the necessary permissions to access the target directory and the destination directory for the backup file. As well as ensure from ssh connection with the remote server to copy the Backed up files on it and change the values of the variables related to the server [REMOTE_USER] [REMOTE_HOST] [REMOTE_DEST_FILE] on the backup function to yours.

## backup.sh Script Usage:
To use this script, follow the steps below:
- Determine the directory you want to backup and ensure that it contains the files you want to backup.
- Open a terminal and navigate to the directory containing the "backup.sh" script.
- Run the script with the following command: "./backup.sh [TARGET_DIR] [DESTINATION_DIR] [ENCRYPTION_KEY] [DAYS]"
- Replace [TARGET_DIR] with the directory containing the files you want to backup.
- Replace [DESTINATION_DIR] with the directory where you want to save the backup file.
- Replace [ENCRYPTION_KEY] with the File that contains passphrase to encrypt the backup file.
- Replace [DAYS] with the number of days for which you want to backup the changed files only.
- Example Usage:
    ```
    ./backup.sh /home/user/myproject /home/user/backups /home/user/passphrase.txt 7
    ```

## restore.sh Script Usage:
To use this script, follow the steps below:
- Ensure that the "backup.sh" script was used to create a backup of the files you want to restore.
- Open a terminal and navigate to the directory containing the "restore.sh" script.
- Run the script with the following command: "./restore.sh [RESTORE_DIR] [DESTINATION_RESTORE_DIR] [DECRYPTION_KEY]"
- Replace [RESTORE_DIR] with the directory where the backup file is stored on the remote server.
- Replace [DESTINATION_RESTORE_DIR] with the directory where you want to restore the files.
- Replace [DECRYPTION_KEY] with the File that contains passphrase that was used to encrypt the backup files.
- Example Usage:
    ```
    ./restore.sh /home/user/backup /home/user/restore /home/user/passphrase.txt
    ```

## Cron job
For example, to run a backup script every day at midnight, you can add the following line to the crontab file: 0 0 * * * /home/user/backup.sh. This will execute the backup.sh script located in the /home/user directory at 12:00am every day.

- For edit crontab file
    ```
    crontab -e
    ```
- Add this line at the bottom of the file then save it
    ```
    0 0 * * * /home/user/backup.sh
    ```

Note that you may need to set environment variables in the script or add them as hard-coded values for the cron job to run correctly.