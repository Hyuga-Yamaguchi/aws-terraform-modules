# CMK
resource "aws_kms_key" "example" {
  description             = "Example Customer Master Key"
  enable_key_rotation     = true # 自動ローテーション 1年に一度
  is_enabled              = true # falseにするとCMKを無効化できる
  deletion_window_in_days = 30   # CMKの削除待機期間　CMKの削除は原則非推奨
}

# エイリアス
resource "aws_kms_alias" "example" {
  name          = "alias/example"
  target_key_id = aws_kms_key.example.id
}
