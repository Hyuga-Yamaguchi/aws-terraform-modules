# ECS cluster
## Docker コンテナを実行するホストサーバーを論理的に束ねるリソース
resource "aws_ecs_cluster" "example" {
  name = "example"
}

# Task Definition
## コンテナ実行時の設定を記述
resource "aws_ecs_task_definition" "example" {
  family                   = "example"                           # タスク定義名のprefix example:1とかになる
  cpu                      = 256                                 # CPUユニットに整数表現
  memory                   = 512                                 # 512MB
  network_mode             = "awsvpc"                            # Fargateの場合はawsvpc
  requires_compatibilities = ["FARGATE"]                         # Fargate指定
  container_definitions    = file("./container_definition.json") # コンテナ定義
}

# ECS Service
## 起動するタスクの数を定義でき、指定した数のタスクを維持する
## なんらかの理由でタスクが終了しても、自動的に新しいタスクを起動する
resource "aws_ecs_service" "example" {
  name                              = "example"
  cluster                           = aws_ecs_cluster.example.arn
  task_definition                   = aws_ecs_task_definition.example.arn
  desired_count                     = 2 # 指定したタスク数が1の場合、コンテナが異常終了するとECSサービスがタスクを再起動するまでアクセスできなくなる 本番環境では2以上を指定する
  launch_type                       = "FARGATE"
  platform_version                  = "1.3.0"
  health_check_grace_period_seconds = 60 # ヘルスチェック猶予期間(秒)

  # サブネットとセキュリティグループを設定
  network_configuration {
    assign_public_ip = false
    security_groups  = [module.nignx_sg.security_group_id]

    subnets = [
      aws_subnet.private_0.id,
      aws_subnet_private_1.id
    ]
  }

  # ターゲットグループとコンテナの名前, ポート番号を指定する
  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "example"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition] # Fargateの場合、デプロイのたびにタスク定義が更新され、plan時に差分が出る。Terraformではタスク定義の変更を無視する。
  }
}

module "nignx_sg" {
  source      = "../network/module"
  name        = "nginx-sg"
  vpc_id      = aws_vpc.example.id
  port        = 80
  cidr_blocks = [aws_vpc.example.cidr_block]
}
