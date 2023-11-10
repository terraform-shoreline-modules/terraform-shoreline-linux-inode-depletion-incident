resource "shoreline_notebook" "inode_depletion_incident" {
  name       = "inode_depletion_incident"
  data       = file("${path.module}/data/inode_depletion_incident.json")
  depends_on = [shoreline_action.invoke_fs_resize_inode,shoreline_action.invoke_inode_remediation]
}

resource "shoreline_file" "fs_resize_inode" {
  name             = "fs_resize_inode"
  input_file       = "${path.module}/data/fs_resize_inode.sh"
  md5              = filemd5("${path.module}/data/fs_resize_inode.sh")
  description      = "Increase the inode limit of the file system by resizing the file system or by using the tune2fs command."
  destination_path = "/tmp/fs_resize_inode.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "inode_remediation" {
  name             = "inode_remediation"
  input_file       = "${path.module}/data/inode_remediation.sh"
  md5              = filemd5("${path.module}/data/inode_remediation.sh")
  description      = "Determine which files and directories can be deleted, archived or moved to another file system to free up inodes."
  destination_path = "/tmp/inode_remediation.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_fs_resize_inode" {
  name        = "invoke_fs_resize_inode"
  description = "Increase the inode limit of the file system by resizing the file system or by using the tune2fs command."
  command     = "`chmod +x /tmp/fs_resize_inode.sh && /tmp/fs_resize_inode.sh`"
  params      = ["FILE_SYSTEM_PATH","INODE_LIMIT"]
  file_deps   = ["fs_resize_inode"]
  enabled     = true
  depends_on  = [shoreline_file.fs_resize_inode]
}

resource "shoreline_action" "invoke_inode_remediation" {
  name        = "invoke_inode_remediation"
  description = "Determine which files and directories can be deleted, archived or moved to another file system to free up inodes."
  command     = "`chmod +x /tmp/inode_remediation.sh && /tmp/inode_remediation.sh`"
  params      = ["PATH_TO_ARCHIVE_DIRECTORY","PATH_TO_OTHER_FILE_SYSTEM","PATH_TO_LOG_FILE"]
  file_deps   = ["inode_remediation"]
  enabled     = true
  depends_on  = [shoreline_file.inode_remediation]
}

