

resource "aws_instance" "ipfs_node" {
  ami                    = data.aws_ami.ubuntu.id
  count                  = var.ipfs_node_count[terraform.workspace]
  iam_instance_profile   = aws_iam_instance_profile.profile.name
  instance_type          = var.ipfs_node_instance_types[terraform.workspace]
  key_name               = aws_key_pair.auth.id
  subnet_id              = aws_subnet.public.0.id
  vpc_security_group_ids = [aws_security_group.ipfs_node.id]
  timeouts {
    create = "30m"
    delete = "10m"
  }
  user_data = templatefile("${abspath(path.root)}/ipfs-node-cloud-init.yml", {
    fqdn             = "${var.prefix}-ipfs-node-${terraform.workspace}-${count.index + 1}.${var.root_domain}"
    prefix           = var.prefix
    ssh_port         = var.ssh_port
    ssh_key_1        = var.ssh_key_1
    ssh_key_2        = var.ssh_key_2
    ipfs_node_number = "${count.index + 1}"
    ipfs_path        = var.ipfs_path
    region           = var.workspace_regions[terraform.workspace]
    workspace        = terraform.workspace
  })
  connection {
    type        = "ssh"
    user        = var.prefix
    port        = var.ssh_port
    host        = self.public_ip
    private_key = file(var.private_key_path)
    agent       = false
  }
  root_block_device {
    volume_size = var.ipfs_node_root_volume_size
  }
  ebs_block_device {
    device_name = "/dev/sdf"
    snapshot_id = length(data.aws_ebs_snapshot_ids.ipfs_data.ids) > 0 ? data.aws_ebs_snapshot_ids.ipfs_data.ids[0] : null
    volume_size = var.ipfs_node_data_volume_size
    volume_type = "gp2"
  }
  tags = {
    Name        = "${var.prefix}-ipfs-node-${terraform.workspace}-${count.index + 1}"
    environment = terraform.workspace
    group       = var.prefix
    type        = "ipfs-node"
  }
  volume_tags = {
    Name        = "${var.prefix}-ipfs-node-${terraform.workspace}-${count.index + 1}"
    environment = terraform.workspace
    group       = var.prefix
    type        = "ipfs-node"
  }
  provisioner "file" {
    source      = "./ipfs-node"
    destination = "/home/${var.prefix}/"
  }
  provisioner "file" {
    source      = "./config/ipfs-node/${terraform.workspace}.env"
    destination = "/home/${var.prefix}/ipfs-node/.env"
  }
  provisioner "file" {
    source      = "./utilities"
    destination = "/home/${var.prefix}/utilities"
  }
  provisioner "remote-exec" {
    inline = ["cloud-init status --wait",
      "find ~ -name '*.sh' | xargs  chmod +x",
      "/home/${var.prefix}/ipfs-node/init.sh"
    ]
  }
}
