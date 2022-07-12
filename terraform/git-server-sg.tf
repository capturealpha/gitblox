resource "aws_security_group" "git_server" {
  name        = "${var.prefix}-git-server-${terraform.workspace}"
  description = "${var.prefix} git server ${terraform.workspace}"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.ip_whitelist
  }
  ingress {
    description     = "${var.prefix} git server"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.git_server_elb.id]
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
    type        = "git-server"
  }
}
