# プライベートネットワーク
# インターネットから隔離されたネットワーク
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.64.0/24" # パブリックサブネットとは異なるIPアドレスレンジにする
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.example.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# NAT Gateway
## プライベートネットワークからインターネットへのアクセスができるようになる。

# EIP(Elastic IP Address)
## Public IP Addressを固定できる
resource "aws_eip" "nat_gateway" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.example] # depends_onでIGW作成後にEIPを作成できるよう保証できる。
}

# NAT Gateway
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public.id # NAT Gatewayを配置するパブリックサブネットを指定する
  depends_on    = [aws_internet_gateway.example]
}

# プライベートサブネットからインターネットへ向かうルート
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.example.id
  destination_cidr_block = "0.0.0.0/0"
}
