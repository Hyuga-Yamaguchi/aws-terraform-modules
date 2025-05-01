resource "aws_s3_bucket" "private" {
  bucket = "private-progmatic-terraform" // 全世界で一意
}

resource "aws_s3_bucket_versioning" "private" {
  bucket = aws_s3_bucket.private.id

  versioning_configuration {
    status = "Enabled" // オブジェクトを変更削除してもいつでも元のバージョンに復元できる
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "private" {
  bucket = aws_s3_bucket.private.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "private" {
  bucket                  = aws_s3_bucket.private.id
  block_public_acls       = true // バケットまたはオブジェクトにパブリックな ACL（アクセス制御リスト）を設定できなくする
  block_public_policy     = true // パブリックアクセスを許可するようなバケットポリシーの設定をブロック
  ignore_public_acls      = true // パブリックな ACL が既に設定されていても無視する
  restrict_public_buckets = true // バケットポリシーがパブリックアクセスを許可している場合でも、S3 側がそのポリシーを無効にする
}
