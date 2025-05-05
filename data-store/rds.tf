# my.cnfに記載するようなDBの設定
resource "aws_db_parameter_group" "example" {
  name   = "example"
  family = "mysql8.4"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_secret"
    value = "utf8mb4"
  }
}

# DBエンジンにオプション機能を追加する
resource "aws_db_option_group" "example" {
  name                 = "example"
  engine_name          = "mysql"
  major_engine_version = "8.4"

  option {
    option_name = "MARIADB_AUDIT_PLUGIN" # MariaDB監査プラグイン　ユーザーのログオンや実行したクエリなどを記録
  }
}

# DBを稼働させるサブネットを指定
resource "aws_db_subnet_group" "example" {
  name       = "example"
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id]
}

resource "aws_db_instance" "example" {
  identifier                 = "example" # DBのエンドポイントで使用する識別子
  engine                     = "mysql"
  engine_version             = "8.4"
  instance_class             = "db.t3.small"
  allocated_storage          = 20
  max_allocated_storage      = 100 # 指定した容量まで自動でスケールする
  storage_type               = "gp2"
  storage_encrypted          = true
  kms_key_id                 = aws_kms_key.example.id # デフォルトAWS KMS暗号化鍵を使用selectedルウと、アカウントを跨いだスナップショットの共有が不可になる
  username                   = "admin"
  password                   = "VeryStrongPassword"
  multi_az                   = true
  publicly_accessible        = false
  backup_window              = "09:10-09:40"         # UTC
  backup_retention_period    = 30                    # 最大35日
  maintenance_window         = "mon:10:10-mon:10:40" # UTC
  auto_minor_version_upgrade = false                 # 自動マイナーアップデートを無効化
  deletion_protection        = true
  skip_final_snapshot        = false
  port                       = 3306
  apply_immediately          = false # RDSでは一部の設定変更に再起動が伴うため、即時変更を避ける
  vpc_security_group_ids     = [module.mysql_sg.security_group_id]
  parameter_group_name       = aws_db_parameter_group.example.name
  option_group_name          = aws_db_option_group.example.name
  db_subnet_group_name       = aws_db_subnet_group.example.name

  lifecycle {
    ignore_changes = [password]
  }
}

module "mysql_sg" {
  source      = "../network/module"
  name        = "mysql-sg"
  vpc_id      = aws_vpc.example.id
  port        = 3306
  cidr_blocks = [aws_vpc.example.cidr_block]
}
