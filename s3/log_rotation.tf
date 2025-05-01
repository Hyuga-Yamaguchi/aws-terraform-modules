resource "aws_s3_bucket" "alb_log" {
  bucket = "alb-log-pragmatic-terraform"
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_log" {
  # 180日経過したファイルを自動的に削除する
  bucket = aws_s3_bucket.alb_log.id

  rule {
    id     = "log-expiration"
    status = "Enabled"

    expiration {
      days = 180
    }

    filter {
      prefix = ""
    }
  }

}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.alb_log.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::XXXXXXXXXXXX:root"]
    }
  }
}
