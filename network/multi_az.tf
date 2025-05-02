# Public subnet
resource "aws_subnet" "public_0" {
  vpc_id                          = aws_vpc.example.id
  cidr_block                      = "10.0.1.0/24"
  availability_zone               = "ap-northeast-1a"
  map_customer_owned_ip_on_launch = true
}

resource "aws_subnet" "public_1" {
  vpc_id                          = aws_vpc.example.id
  cidr_block                      = "10.0.2.0/24"
  availability_zone               = "ap-northeast-1c"
  map_customer_owned_ip_on_launch = true
}

resource "aws_route_table_association" "public_0" {
  subnet_id      = aws_subnet.public_0.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# Private subnet
resource "aws_subnet" "private_0" {
  vpc_id                          = aws_vpc.example.id
  cidr_block                      = "10.0.65.0/24"
  availability_zone               = "ap-northeast-1a"
  map_customer_owned_ip_on_launch = false
}

resource "aws_subnet" "private_1" {
  vpc_id                          = aws_vpc.example.id
  cidr_block                      = "10.0.66.0/24"
  availability_zone               = "ap-northeast-1c"
  map_customer_owned_ip_on_launch = false
}

resource "aws_eip" "nat_gateway_0" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.example]
}

resource "aws_eip" "nat_gateway_1" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.example]
}

# NAT GWを単体で使用した場合、NAT GWが属するAZに障害が発生すると、もう片方のAZでも通信ができなくなる。
# NAT GWはAZごとに作成する。
resource "aws_nat_gateway" "nat_gateway_0" {
  allocation_id = aws_eip.nat_gateway_0.id
  subnet_id     = aws_subnet.public_0.id
  depends_on    = [aws_internet_gateway.example]
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_gateway_1.id
  subnet_id     = aws_subnet.public_1.id
  depends_on    = [aws_internet_gateway.example]
}

# Default Routeは一つのルートテーブルにつき、一つしか定義できない。
# ルートテーブルもAZごとに作成する
resource "aws_route_table" "private_0" {
  vpc_id = aws_vpc.example.id
}

resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.example.id
}

resource "aws_route" "private_0" {
  route_table_id         = aws_route_table.private_0.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway_0.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private_1" {
  route_table_id         = aws_route_table.private_1.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway_1.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_0" {
  subnet_id      = aws_subnet.private_0.id
  route_table_id = aws_route_table.private_0.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}
