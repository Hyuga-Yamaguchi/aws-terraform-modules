resource "aws_s3_bucket" "public" {
  bucket = "public-pragmatic-terraform"
}

resource "aws_s3_bucket_ownership_controls" "public" {
  # S3バケット内のオブジェクトの所有者の扱い方を定義する
  # ACLを設定するには必要
  bucket = aws_s3_bucket.public.id

  rule {
    object_ownership = "BucketOwnershipPreferred" # 常にバケット所有者をオブジェクト所有者にする
  }

}

resource "aws_s3_bucket_public_access_block" "public" {
  # パブリックアクセスの許可制御
  bucket = aws_s3_bucket.private.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_acl" "public" {
  # 基本的にバケットポリシーやIAMポリシーが推奨
  # シンプルなパブリックホスティングをする場合に有効
  depends_on = [aws_s3_bucket_ownership_controls.public]
  bucket     = aws_s3_bucket.public.id
  acl        = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "public" {
  bucket = aws_s3_bucket.public.id

  cors_rule {
    allowed_origins = ["https://example.com"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}
