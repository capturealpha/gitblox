resource "aws_security_group" "ipfs_node" {
  name        = "${var.prefix}-ipfs-node-${terraform.workspace}"
  description = "${var.prefix} ipfs node ${terraform.workspace}"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.ip_whitelist
  }
  ingress {
    description     = "${var.prefix} gateway"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.ipfs_node_elb.id]
  }
  ingress {
    description = "${var.prefix} p2p"
    from_port   = 4001
    to_port     = 4001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description     = "${var.prefix} api"
    from_port       = 5001
    to_port         = 5001
    protocol        = "tcp"
    security_groups = []
  }
  egress {
    description = "outbound internet access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    environment = terraform.workspace
    group       = var.prefix
    type        = "ipfs-node"
  }
}
