#!/bin/bash

source backup_restore_lib.sh

validate_backup_params $1 $2 $3 $4
validate_exit_code=$?

if [[ $validate_exit_code == 1 ]]; then
    echo -e "\e[41mError: Backup Faild.\e[0m"
elif [[ $validate_exit_code != 1 && $validate_exit_code != 2 ]]; then
    backup
fi