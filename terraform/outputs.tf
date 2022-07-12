output "ipfs-node-ip" {
  value = aws_instance.ipfs_node.*.public_ip
}
output "git-server-ip" {
  value = aws_instance.git_server.*.public_ip
}
output "prefix" {
  value = var.prefix
}
output "env" {
  value = terraform.workspace
}
