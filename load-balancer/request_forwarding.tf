# リクエストフォワーディング
## 任意のターゲットへ、リクエストをフォワードする

# Target Group
## ALBがリクエストをフォワードする対象
resource "aws_lb_target_group" "example" {
  name        = "exmaple"
  target_type = "ip" # ECS Fargate

  # ルーティング先
  vpc_id   = aws_vpc.exmaple.id
  port     = 80
  protocol = "HTTP" # HTTPSの終端はALBなので、HTTPを指定することが多い

  deregistration_delay = 300 # ターゲットの登録を解除する前にALBが待機する時間(秒)

  health_check {
    path                = "/"            # ヘルスチェックで使用するパス
    healthy_threshold   = 5              # 正常判定を行うまでのヘルスチェック実行回数
    unhealthy_threshold = 2              # 異常判定を行うまでのヘルスチェック実行回数
    timeout             = 5              # ヘルスチェックのタイムアウト時間(秒)
    interval            = 30             # ヘルスチェックの実行間隔(秒)
    matcher             = 200            # 正常判定を行うために使用するHTTPステータス
    port                = "traffic-port" # ヘルスチェックで使用するポート ルーティング先のポート
    protocol            = "HTTP"         # ヘルスチェック時に使用するプロトコル
  }

  depends_on = [aws_lb.example]
}

resource "aws_lb_listener_rule" "example" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100 # 数字が小さいほど優先順位が高い

  # ターゲットグループを設定
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }

  condition {
    path_pattern {
      values = ["/"] # 全てのpathをマッチする
    }
  }
}
