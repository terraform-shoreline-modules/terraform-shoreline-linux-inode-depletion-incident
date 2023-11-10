#!/bin/bash

# Set variables
${FILE_SYSTEM_PATH}="/dev/sda1" # Replace with the path to your file system
${INODE_LIMIT}="1000000" # Replace with the desired inode limit

# Check if filesystem is mounted
if mount | grep ${FILE_SYSTEM_PATH} > /dev/null; then
    # Resize the file system
    sudo resize2fs ${FILE_SYSTEM_PATH}

    # Increase the inode limit
    sudo tune2fs -O resize_inode -I ${INODE_LIMIT} ${FILE_SYSTEM_PATH}

    echo "File system inode limit increased to ${INODE_LIMIT}."
else
    echo "File system ${FILE_SYSTEM_PATH} is not mounted."
fi