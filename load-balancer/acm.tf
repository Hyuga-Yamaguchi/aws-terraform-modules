# SSL証明書
resource "aws_acm_certificate" "example" {
  domain_name               = aws_route53_record.example.name # *.example.comでワイルド証明書
  subject_alternative_names = []                              # ドメイン名を追加する
  validation_method         = "DNS"                           # SSL証明書を自動更新する場合はDNS

  lifecycle {
    create_before_destroy = true # リソースを作成してから古いリソースを削除する
  }
}

# 検証用DNSレコード
resource "aws_route53_record" "example_certificate" {
  for_each = {
    for dvo in aws_acmaws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  name    = each.value.name
  type    = each.value.type
  zone_id = data.aws_route53_zone.example.id
  records = [each.value.value]
  ttl     = 60
}

# 検証の待機
## Apply時にSSL証明書の検証が完了するまで待ってくれる
resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.example.arn
  validation_record_fqdns = [aws_route53_record.example_certificate.fqdn]
}
