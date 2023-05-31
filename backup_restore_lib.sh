#!/bin/bash

function validate_backup_params {

    export TARGET_DIR=$1
    export DESTINATION_DIR=$2
    export ENCRYPTION_KEY=$3
    export DAYS=$4
    export BACKUP_DATE=$(date | sed "s/ /_/g" | sed "s/:/_/g")

    # Validate Parametters Number
    if [[ $# == 0 ]]; then
        echo -e "\e[46mHelp Message: To use this script you should pass a 4 Parameters\n 1- The Target Directory that you want to Backup.\n 2- The Destination Directory that you want to save the Backedup Directory inside.\n 3- The Enceryption Key you that will use to encerypt and decrypt the siles\n 4- Number of DAYS that should use to backup only the changed files during the last n DAYS.\e[0m"
        return 2
    fi

    if [[ $# < 4 ]]; then
        echo -e "\e[41mError: You should pass enough Parameters.\e[0m"
        return 1
    fi

    # Validate Target Directory
    if [[ $TARGET_DIR == "" ]]; then
        echo -e "\e[41mError: You should write the path for the target directory.\e[0m"
        return 1
    fi

    if [[ $TARGET_DIR != /* ]]; then
        echo -e "\e[41mError: You should write an absolute path for the target directory.\e[0m"
        return 1
    fi

    if [[ ! -e "$TARGET_DIR" ]]; then
        echo -e "\e[41mError: You should write an exist target directory.\e[0m"
        return 1
    fi

    if [[ $(ls $TARGET_DIR) == "" ]]; then
        echo -e "\e[41mError: The target directory is empty.\e[0m"
        return 1
    fi

    # Validate Destination Directory
    if [[ $DESTINATION_DIR == "" ]]; then
        echo -e "\e[41mError: You should write the path for the Destination directory.\e[0m"
        return 1
    fi

    if [[ $DESTINATION_DIR != /* ]]; then
        echo -e "\e[41mError: You should write an absolute path for the Destination directory.\e[0m"
        return 1
    fi

    if [[ ! -e "$DESTINATION_DIR" ]]; then
        echo -e "\e[41mError: Destination directory not exist.\e[0m"
        return 1
    fi

    # Validate Encryption Key
    if [[ $ENCRYPTION_KEY == "" ]]; then
        echo -e "\e[41mError: You should write the path for the Encryption Key.\e[0m"
        return 1
    fi

    if [[ ! -f "$ENCRYPTION_KEY" ]]; then
        echo -e "\e[41mError: Encryption Key not exist.\e[0m"
        return 1
    fi

    if [[ ! -r "$ENCRYPTION_KEY" ]]; then
        echo -e "\e[41mError: Encryption Key not Readable.\e[0m"
        return 1
    fi
}

function backup {
    REMOTE_USER="ubuntu"
    REMOTE_HOST="3.85.103.180"
    REMOTE_DEST_FILE="/home/ubuntu"
    CURRENT_TIME=$(date +%s)
    mkdir $DESTINATION_DIR/$BACKUP_DATE
    cd $TARGET_DIR
    for i in $(ls); do
        MOD_TIME=$(stat -c %Y "$i")
        TIME_DIFF=$(((CURRENT_TIME - MOD_TIME) / 86400))

        if [[ $TIME_DIFF < $DAYS ]]; then
            
            if [[ -d "$i" ]]; then
                tar -cf "$DESTINATION_DIR/$BACKUP_DATE/$i-$BACKUP_DATE.tar" -C "$TARGET_DIR" "$i"
                gzip "$DESTINATION_DIR/$BACKUP_DATE/$i-$BACKUP_DATE.tar"
                gpg -c --batch --no-symkey-cache --passphrase-file $ENCRYPTION_KEY "$DESTINATION_DIR/$BACKUP_DATE/$i-$BACKUP_DATE.tar.gz"
                rm "$DESTINATION_DIR/$BACKUP_DATE/$i-$BACKUP_DATE.tar.gz"
            fi

            if [[ -f "$i" ]]; then
                if [ -e "$DESTINATION_DIR/$BACKUP_DATE/files-$BACKUP_DATE.tar" ]; then
                    tar --update --file="$DESTINATION_DIR/$BACKUP_DATE/files-$BACKUP_DATE.tar" $i
                else
                    tar --create --file="$DESTINATION_DIR/$BACKUP_DATE/files-$BACKUP_DATE.tar" $i
                fi
            fi
        fi

    done
    if [[ -e "$DESTINATION_DIR/$BACKUP_DATE/files-$BACKUP_DATE.tar" ]]; then
        cd $DESTINATION_DIR/$BACKUP_DATE
        gzip files-$BACKUP_DATE.tar
        gpg -c --batch --no-symkey-cache --passphrase-file $ENCRYPTION_KEY "files-$BACKUP_DATE.tar.gz"
        rm "files-$BACKUP_DATE.tar.gz"
    fi
    scp -r "$DESTINATION_DIR/$BACKUP_DATE" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DEST_FILE" &> /dev/null
    if [[ "$?" == 0 ]]; then
        echo -e "\e[46mBackup Is Done, And the Directory Backup copied successfully to the remote server.\e[0m"
    else
        echo -e "\e[46mBackup Is Done, But the Directory failed to copy to the remote server. Check the connection.\e[0m"
    fi
}

function validate_restore_params {

    export RESTORE_DIR=$1
    export DESTINATION_RESTORE_DIR=$2
    export DECRYPTION_KEY=$3

    # Validate Parametters Number
    if [[ $# == 0 ]]; then
        echo -e "\e[46mHelp Message: To use this script you should pass a 3 Parameters\n 1- The Backup Directory that you want to Restore.\n 2- The Destination Directory that you want to save the Restored Files inside.\n 3- The Deceryption Key that you will use to decrypt the Files.\e[0m"
        return 2
    fi

    if [[ $# < 3 ]]; then
        echo -e "\e[41mError: You should pass enough Parameters.\e[0m"
        return 1
    fi

    # Validate Target Directory
    if [[ $RESTORE_DIR == "" ]]; then
        echo -e "\e[41mError: You should write the path for the target directory that you want to Restore.\e[0m"
        return 1
    fi

    if [[ $RESTORE_DIR != /* ]]; then
        echo -e "\e[41mError: You should write an absolute path for the target directory that you want to Restore.\e[0m"
        return 1
    fi

    if [[ ! -e "$RESTORE_DIR" ]]; then
        echo -e "\e[41mError: You should write an exist target directory.\e[0m"
        return 1
    fi

    if [[ $(ls $RESTORE_DIR) == "" ]]; then
        echo -e "\e[41mError: The target directory is empty.\e[0m"
        return 1
    fi

    # Validate Destination Directory
    if [[ $DESTINATION_RESTORE_DIR == "" ]]; then
        echo -e "\e[41mError: You should write the path for the Destination directory.\e[0m"
        return 1
    fi

    if [[ $DESTINATION_RESTORE_DIR != /* ]]; then
        echo -e "\e[41mError: You should write an absolute path for the Destination directory.\e[0m"
        return 1
    fi

    if [[ ! -e "$DESTINATION_RESTORE_DIR" ]]; then
        echo -e "\e[41mError: Destination directory not exist.\e[0m"
        return 1
    fi

    # Validate decryption Key
    if [[ $DECRYPTION_KEY == "" ]]; then
        echo -e "\e[41mError: You should write the path for the Decryption Key.\e[0m"
        return 1
    fi

    if [[ ! -f "$DECRYPTION_KEY" ]]; then
        echo -e "\e[41mError: Decryption Key not exist.\e[0m"
        return 1
    fi

    if [[ ! -r "$DECRYPTION_KEY" ]]; then
        echo -e "\e[41mError: Decryption Key not Readable.\e[0m"
        return 1
    fi
    
}

function restore {
    mkdir $DESTINATION_RESTORE_DIR/temp
    cd $RESTORE_DIR
    for i in $(ls | grep .gpg); do             
        gpg -d --batch --no-symkey-cache --passphrase-file $DECRYPTION_KEY --output $DESTINATION_RESTORE_DIR/temp/"${i%.*}" "$i"
    done

    cd $DESTINATION_RESTORE_DIR/temp
    for i in $(ls | grep .gz); do             
        tar -xzf "$DESTINATION_RESTORE_DIR/temp/$i" -C "$DESTINATION_RESTORE_DIR"   
    done
    rm -rf $DESTINATION_RESTORE_DIR/temp
    echo -e "\e[46mRestore Is Done.\e[0m"

}

