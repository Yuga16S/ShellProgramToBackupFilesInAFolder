#!/bin/bash

main() {

    ############ NOTE ########################################
    # Update the variables below if you want to backup a     #
    # different directory other than home                    #
    # and/or backup to a different directory                 #
    ##########################################################


    ## created a custom_home directory mocking actual home to avoid permission errors
    HOME=/Users/yugapriya/Desktop/term2/ASP/assg4/backup_home
    BACKUP_HOME=$HOME/backup/cb
    INCREMENTAL_BACKUP_HOME=$HOME/backup/ib


    # Starting sequences used for naming the tars 
    CB_COUNT=20000;
    IB_COUNT=10000;

    PREV_BACKUP_TIMESTAMP=$(date);

    iteration=0;

    # delete any prexisting log in the current directory
    rm -rf backup.log;

    # delete any prexisting backups
    rm -rf ${BACKUP_HOME}/*
    rm -rf ${INCREMENTAL_BACKUP_HOME}/*

    while true; do

        if [[ $((iteration % 4)) -eq 0 ]]; then

            # Complete backup for iterations 0, 4, 8, 12 ...
            CB_COUNT=$((CB_COUNT+1));
            BACKUP_FOLDER_NAME=cb${CB_COUNT};
            BACKUP_DIR=${BACKUP_HOME}/${BACKUP_FOLDER_NAME};

            #echo taking complete backup;

            for file_name in `find $HOME -name "*.txt" -type f`; do
                #echo file_name: ${file_name};

                file_basename=`basename ${file_name}`;
                #echo file_basename: ${file_basename};

                file_dir=`dirname ${file_name}`;
                #echo file_dir: ${file_dir};

                dest_dir=${file_dir/$HOME/"${BACKUP_DIR}"};
               # echo dest_dir: ${dest_dir};

                mkdir -p ${dest_dir};

                cp ${file_name} ${dest_dir}/${file_basename};

                #echo ${file_name} ${dest_dir}/${file_basename};
            done

            PREV_BACKUP_TIMESTAMP=$(date);

            ### changing into the backup folder's parent directory to generate the tar and then changing back to the original current directory ###
            ORIG_DIR=`pwd`;
            cd ${BACKUP_DIR}/..;
            tar -cf ./${BACKUP_FOLDER_NAME}.tar ./${BACKUP_FOLDER_NAME};
            rm -rf ./${BACKUP_FOLDER_NAME};
            cd ${ORIG_DIR};

            echo ${PREV_BACKUP_TIMESTAMP} ${BACKUP_FOLDER_NAME}.tar was created >> backup.log;
        else 

            # Incremental backup for other iterations
            IB_COUNT=$((IB_COUNT+1));
            BACKUP_FOLDER_NAME=ib${IB_COUNT};
            BACKUP_DIR=${INCREMENTAL_BACKUP_HOME}/${BACKUP_FOLDER_NAME};
            #echo ${BACKUP_DIR};

            #echo taking incremental backup;

            has_modified_files=false;

            for file_name in `find $HOME -name "*.txt" -type f -newermt "${PREV_BACKUP_TIMESTAMP}"`; do
                has_modified_files=true;

                #echo file_name: ${file_name};

                file_basename=`basename ${file_name}`;
                #echo file_basename: ${file_basename};

                file_dir=`dirname ${file_name}`;
                #echo file_dir: ${file_dir};

                dest_dir=${file_dir/$HOME/"${BACKUP_DIR}"};
                #echo dest_dir: ${dest_dir};

                mkdir -p ${dest_dir};

                cp ${file_name} ${dest_dir}/${file_basename};

                #echo ${file_name} ${dest_dir}/${file_basename};
            done

            if [[ "${has_modified_files}" = "true" ]]; then

                PREV_BACKUP_TIMESTAMP=$(date);

                ### changing into the backup folder's parent directory to generate the tar and then changing back to the original current directory ###
                ORIG_DIR=`pwd`;
                cd ${BACKUP_DIR}/..;
                tar -cf ./${BACKUP_FOLDER_NAME}.tar ./${BACKUP_FOLDER_NAME};
                rm -rf ./${BACKUP_FOLDER_NAME};
                cd ${ORIG_DIR};

                echo ${PREV_BACKUP_TIMESTAMP} ${BACKUP_FOLDER_NAME}.tar was created >> backup.log;
            else 
                # no modified since last complete backup
                echo  $(date) No changes-Incremental backup was not created  >> backup.log;

                # restoring the original count since no backup was created
                IB_COUNT=$((IB_COUNT-1)); 
            fi
        fi

        iteration=$((iteration+1));
        sleep 120; # sleep for 2 minutes

    done;
}


# the entire program wrapped inside main block is executed in the background
main &

