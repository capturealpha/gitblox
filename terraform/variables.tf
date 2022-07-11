variable "workspace_regions" {
  default = {
    default = "us-west-2"
    develop = "us-west-2"
    stage   = "us-east-2"
    prod    = "us-east-1"
  }
}

variable "workspace_azs" {
  default = {
    default = ["us-west-2a", "us-west-2b", "us-west-2c"]
    develop = ["us-west-2a", "us-west-2b", "us-west-2c"]
    stage   = ["us-east-2a", "us-east-2b", "us-east-2c", "us-east-2d", "us-east-2e", "us-east-2f"]
    prod    = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
  }
}

variable "ipfs_node_instance_types" {
  default = {
    default = "t3a.medium"
    develop = "t3a.medium"
    stage   = "t3a.large"
    prod    = "t3a.large"
  }
}

variable "ipfs_node_count" {
  default = {
    default = 1
    develop = 1
    stage   = 1
    prod    = 1
  }
}

variable "prefix" {
  description = "Name of project being deployed for naming and tagging"
}

variable "ssh_port" {
  description = "sshd daemon listening port"
  default     = "22"
}

variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.

Example: ~/.ssh/terraform.pub
DESCRIPTION

  default = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  description = <<DESCRIPTION
Path to the SSH private key to be used for authentication.

Example: ~/.ssh/id_rsa
DESCRIPTION

  default = "~/.ssh/id_rsa"
}

variable "ipfs_node_root_volume_size" {
  description = "Desired root volume size in GB"
  default     = "16"
}

variable "ipfs_node_data_volume_size" {
  description = "Desired chain data volume size in GB"
  default     = "16"
}

variable "swap_size" {
  description = "Desired swap file size in GB"
  default     = "2"
}

variable "ubuntu_account_number" {
  description = "AMI owner ID"
  default     = "099720109477"
}

variable "indexer_snapshot_name" {
  description = "Graph indexer data snapshot name"
  default     = "indexer_data"
}

variable "ipfs_snapshot_name" {
  description = "IPFS data snapshot name"
  default     = "ipfs_data"
}

variable "root_domain" {
  description = "DNS root domain lookup"
}

variable "ip_whitelist" {
  description = "List of ip/cidr to be whitelisted for each ec2 instance"
}

variable "ssh_key_1" {
  description = "ssh key to add to allowed_hosts"
}

variable "ssh_key_2" {
  description = "ssh key to add to allowed_hosts"
}

variable "ipfs_path" {
  description = "IPFS path for data storage"
  default     = "/data/gitblox"
}
