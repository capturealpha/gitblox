resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name        = "${var.prefix}-${terraform.workspace}"
    environment = terraform.workspace
    group       = var.prefix
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "${var.prefix}-${terraform.workspace}"
    environment = terraform.workspace
    group       = var.prefix
  }
}

resource "aws_route" "public" {
  route_table_id = aws_vpc.main.main_route_table_id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_subnet" "public" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${10 + count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name        = "public-${data.aws_availability_zones.available.names[count.index]}-${var.prefix}-${terraform.workspace}"
    environment = terraform.workspace
    group       = var.prefix
  }
}

resource "aws_subnet" "private" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${20 + count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name        = "private-${data.aws_availability_zones.available.names[count.index]}-${var.prefix}-${terraform.workspace}"
    environment = terraform.workspace
    group       = var.prefix
  }
}
