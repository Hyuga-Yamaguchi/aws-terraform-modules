# Redisの設定
resource "aws_elasticache_parameter_group" "example" {
  name   = "example"
  family = "redis5.0"

  parameter {
    name  = "cluster-enabled"
    value = "no"
  }
}

resource "aws_elasticache_subnet_group" "example" {
  name       = "example"
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id]
}

resource "aws_elasticache_replication_group" "example" {
  replication_group_id       = "example"
  description                = "Cluster Disabled"
  engine                     = "redis"
  engine_version             = "6.x"
  num_cache_clusters         = 3 # ノード数 プライマリーノード: 1, レプリカノード: 2
  node_type                  = "cache:t3.medium"
  snapshot_window            = "09:10-09:40"
  snapshot_retention_limit   = 7
  maintenance_window         = "mon:10:40-mon:11:40"
  automatic_failover_enabled = true
  port                       = 6379
  apply_immediately          = false
  security_group_ids         = [module.redis_sg.security_group_id]
  parameter_group_name       = aws_elasticache_parameter_group.example.name
  subnet_group_name          = aws_elasticache_subnet_group.example.name
}

module "redis_sg" {
  source      = "../network/module"
  name        = "redis-sg"
  vpc_id      = aws_vpc.example.id
  port        = 6379
  cidr_blocks = [aws_vpc.example.cidr_block]
}
