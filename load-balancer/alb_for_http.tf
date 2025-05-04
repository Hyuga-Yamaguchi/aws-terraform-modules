module "http_sg" {
  source      = "../network/module"
  name        = "http-sg"
  vpc_id      = aws_vpc.exxample.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}

module "https_sg" {
  source      = "../network/module"
  name        = "https-sg"
  vpc_id      = aws_vpc.exxample.id
  port        = 443
  cidr_blocks = ["0.0.0.0/0"]
}

module "http_redirect_sg" {
  source      = "../network/module"
  name        = "http-redirect-sg"
  vpc_id      = aws_vpc.exxample.id
  port        = 8080
  cidr_blocks = ["0.0.0.0/0"]
}

# ALB
resource "aws_lb" "example" {
  name                       = "exmaple"
  load_balancer_type         = "application" # ALB
  internal                   = false         # インターネット向け
  idle_timeout               = 60
  enable_deletion_protection = true # 削除保護

  # ALBが所属するサブネット
  # 異なるAZのサブネットを指定して、クロスゾーン負荷分散を実現
  subnets = [
    aws_subnet.public_0.id,
    aws_subnet.public_1.id
  ]

  access_logs {
    bucket  = aws_s3_bucket.alb_log.id
    enabled = true
  }

  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id,
    module.http_redirect_sg.security_group_id
  ]
}

# リスナー
## どのポートのリクエストを受けるかを設定
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = "80"
  protocol          = "HTTP" # ALBはHTTPとHTTPSのみ

  # 複数のルールを設定して異なるアクションを実行できる。
  # いずれのルールにも合致しない場合、default_actionが実行される
  default_action {
    type = "fixed-response" # 固定のHTTPレスポンスを応答
    fixed_response {
      content_type = "text/plain"
      message_body = "This is HTTP"
      status_code  = "200"
    }
  }
}
