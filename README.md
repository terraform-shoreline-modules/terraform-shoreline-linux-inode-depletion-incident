
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Inode Depletion Incident.

Inode depletion is an incident that occurs when the number of available inodes on a file system is exhausted. Inodes are data structures used to store information about each file and directory in a file system. When an inode is created, it is assigned a unique identifier which is used to access and manage the file or directory. If the file system runs out of inodes, it can cause issues such as preventing file creation or causing other file system errors. This can lead to system instability and affect users' ability to access and use files and data.

### Parameters

```shell
export FILESYSTEM_PATH="PLACEHOLDER"
export FILE_SYSTEM_PATH="PLACEHOLDER"
export INODE_LIMIT="PLACEHOLDER"
export PATH_TO_ARCHIVE_DIRECTORY="PLACEHOLDER"
export PATH_TO_LOG_FILE="PLACEHOLDER"
export PATH_TO_OTHER_FILE_SYSTEM="PLACEHOLDER"
```

## Debug

### Check the number of inodes used and available for the filesystem where the incident occurred

```shell
df -i ${FILESYSTEM_PATH}
```

### Check the number of inodes used and available for all mounted filesystems

```shell
df -i
```

### Check which directories are using the most inodes

```shell
sudo find ${FILESYSTEM_PATH} -xdev -type f | cut -d "/" -f 2 | sort | uniq -c | sort -n
```

### Check which files are using the most inodes

```shell
sudo find ${FILESYSTEM_PATH} -xdev -type f | cut -d "/" -f 2- | grep -v "/$" | sort | uniq -c | sort -rn | head
```

### Check which users are using the most inodes

```shell
sudo find ${FILESYSTEM_PATH} -xdev -printf '%u\n' | sort | uniq -c | sort -n
```

### Check if there are any large log files that could be deleted to free up inodes

```shell
sudo find ${FILESYSTEM_PATH} -xdev -type f -name "*.log" -size +100M -exec ls -lh {} \;
```

### Check if there are any large temporary files that could be deleted to free up inodes

```shell
sudo find ${FILESYSTEM_PATH} -xdev -type f -name "*.tmp" -size +100M -exec ls -lh {} \;
```

## Repair

### Increase the inode limit of the file system by resizing the file system or by using the tune2fs command.

```shell
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
```

### Determine which files and directories can be deleted, archived or moved to another file system to free up inodes.

```shell
#!/bin/bash

# Define variables
LOG_FILE="${PATH_TO_LOG_FILE}"
ARCHIVE_DIR="${PATH_TO_ARCHIVE_DIRECTORY}"
OTHER_FILESYSTEM="${PATH_TO_OTHER_FILE_SYSTEM}"

# Log start of script
echo "$(date) - Starting inode remediation script" >> "$LOG_FILE"

# List files and directories by inode usage and save to log file
echo "$(date) - Listing files and directories by inode usage" >> "$LOG_FILE"
find / -xdev -printf '%h\n' | sort | uniq -c | sort -k 1 -n >> "$LOG_FILE"

# Identify files and directories to remediate
echo "$(date) - Identifying files and directories to remediate" >> "$LOG_FILE"
FILES_TO_DELETE=$(find / -xdev -printf '%h\n' | sort | uniq -c | sort -k 1 -n | head -n 10 | awk '{print $2}')
FILES_TO_ARCHIVE=$(find / -xdev -printf '%h\n' | sort | uniq -c | sort -k 1 -n | head -n 10 | awk '{print $2}')
FILES_TO_MOVE=$(find / -xdev -printf '%h\n' | sort | uniq -c | sort -k 1 -n | head -n 10 | awk '{print $2}')

# Delete identified files
echo "$(date) - Deleting files" >> "$LOG_FILE"
for file in $FILES_TO_DELETE; do
    rm -rf "$file"
done

# Archive identified files
echo "$(date) - Archiving files" >> "$LOG_FILE"
for file in $FILES_TO_ARCHIVE; do
    tar -czvf "$ARCHIVE_DIR/$(basename $file).tar.gz" "$file"
done

# Move identified files to other file system
echo "$(date) - Moving files to other file system" >> "$LOG_FILE"
for file in $FILES_TO_MOVE; do
    mv "$file" "$OTHER_FILESYSTEM"
done

# Log end of script
echo "$(date) - Inode remediation script complete" >> "$LOG_FILE"
```