data "aws_route53_zone" "root" {
  name         = var.root_domain
  private_zone = false
}

resource "aws_route53_record" "ipfs_gateway" {
  zone_id = data.aws_route53_zone.root.zone_id
  count   = var.ipfs_node_count[terraform.workspace]
  name    = "ipfs-gateway.${terraform.workspace}.${var.root_domain}"
  type    = "A"
  alias {
    name                   = aws_elb.ipfs[count.index].dns_name
    zone_id                = aws_elb.ipfs[count.index].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ipfs_node" {
  zone_id = data.aws_route53_zone.root.zone_id
  count   = var.ipfs_node_count[terraform.workspace]
  name    = "ipfs-${count.index}.${terraform.workspace}.${var.root_domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.ipfs_node[count.index].public_ip]
}

resource "aws_route53_record" "git_elb" {
  zone_id = data.aws_route53_zone.root.zone_id
  count   = var.git_server_count[terraform.workspace]
  name    = "git.${terraform.workspace}.${var.root_domain}"
  type    = "A"
  alias {
    name                   = aws_elb.git[count.index].dns_name
    zone_id                = aws_elb.git[count.index].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "git_server" {
  zone_id = data.aws_route53_zone.root.zone_id
  count   = var.git_server_count[terraform.workspace]
  name    = "git-server-${count.index}.${terraform.workspace}.${var.root_domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.git_server[count.index].public_ip]
}