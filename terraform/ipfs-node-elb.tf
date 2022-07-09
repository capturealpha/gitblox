resource "aws_security_group" "ipfs_node_elb" {
  name        = "${var.prefix}-ipfs-node-elb-${terraform.workspace}"
  description = "${var.prefix} ipfs-node ELB ${terraform.workspace}"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "outbound internet access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "ipfs" {
  name            = "${var.prefix}-ipfs-${terraform.workspace}-${count.index + 1}"
  count           = var.ipfs_node_count[terraform.workspace]
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.ipfs_node_elb.id]
  instances       = [aws_instance.ipfs_node[count.index].id]

  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = data.aws_acm_certificate.cert.arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name        = "${var.prefix}-${terraform.workspace}-${count.index + 1}"
    environment = terraform.workspace
    group       = var.prefix
    type        = "ipfs"
  }
}
