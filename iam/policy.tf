
data "aws_iam_policy_document" "allow_describe_regions" {
  statement {
    effect    = "Allow"                 // Allow or Deny
    actions   = ["ec2:DescribeRegions"] // なんのサービスでどんな操作が実行できるか
    resources = [""]                    // 操作可能なリソース
  }
}

resource "aws_iam_policy" "example" {
  name   = "example"
  policy = data.aws_iam_policy_document.allow_describe_regions.json
}
