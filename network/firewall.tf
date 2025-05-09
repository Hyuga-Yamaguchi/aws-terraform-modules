# SGを使うとOSへ到達する前にL3でパケットをフィルタリングできる

resource "aws_security_group" "example" {
  name   = "example"
  vpc_id = aws_vpc.example.id # このセキュリティグループを属させるVPC
}

# HTTPをどこからでも受信許可
resource "aws_security_group_rule" "ingress_example" {
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.example.id
}

# すべてのプロトコル/ポートをどこでも送信許可
resource "aws_security_group_rule" "egress_example" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.example.id
}
