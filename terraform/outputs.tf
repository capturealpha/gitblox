output "ipfs-node-ip" {
  value = aws_instance.ipfs_node.*.public_ip
}
output "prefix" {
  value = var.prefix
}
output "env" {
  value = terraform.workspace
}
