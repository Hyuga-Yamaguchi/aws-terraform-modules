# VPC 他のネットワークから切り離されている仮想ネットワーク
resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16" # VPCのアドレス範囲 一度設定したら変更不可
  enable_dns_support   = true          # AWSのDNSサーバによる名前解決を有効にする
  enable_dns_hostnames = true          # VPC内のリソースにパブリックDNSホスト名を自動的に割り当てる

  tags = {
    Name = "example"
  }
}

# Subnet VPCを分割したもの
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.0.0/24"     # 分割したUPアドレス範囲
  map_public_ip_on_launch = true              # このサブネットで起動したインスタンスにパブリックIPアドレスを自動で割り当てる
  availability_zone       = "ap-northeast-1a" # サブネットを作成するAZを指定。AZに跨ったサブネットは作成できない。
}

# Internet Gateway VPCは単位ではインターネットと接続できず、これが必要
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

# Route Table
# VPC内の通信を有効にするため、ローカルルートが自動で設定される
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id
}

# Public Route(0.0.0.0/0 -> IGW)
## ルートテーブルの1レコードに該当する。
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.example.id
  destination_cidr_block = "0.0.0.0/0" # VPC以外への通信を、IGW経由でインターネットへデータを流すために、デフォルトルートを指定する。
}

# Route Table Association
# 関連付けを忘れた場合、デフォルトルートテーブルが自動的に使われる
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
