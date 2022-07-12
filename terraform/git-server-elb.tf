resource "aws_security_group" "git_server_elb" {
  name        = "${var.prefix}-git-server-elb-${terraform.workspace}"
  description = "${var.prefix} git-server ELB ${terraform.workspace}"
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

resource "aws_elb" "git" {
  name            = "${var.prefix}-git-${terraform.workspace}-${count.index + 1}"
  count           = var.git_server_count[terraform.workspace]
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.git_server_elb.id]
  instances       = [aws_instance.git_server[count.index].id]

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = data.aws_acm_certificate.cert.arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/test-repo/info/refs"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name        = "git-${var.prefix}-${terraform.workspace}-${count.index + 1}"
    environment = terraform.workspace
    group       = var.prefix
    type        = "git"
  }
}
