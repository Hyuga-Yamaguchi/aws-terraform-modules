# CloudWatch Logs
resource "aws_cloudwatch_log_group" "for_ecs" {
  name              = "/ecs/example"
  retention_in_days = 180
}

# IAM ポリシードキュメント（CloudWatch Logs, ECR, SSM, KMSなどに必要な権限）
data "aws_iam_policy_document" "ecs_task_execution" {
  statement {
    sid    = "ECSExecutionAccess"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ssm:GetParameters",
      "kms:Decrypt"
    ]

    resources = ["*"]
  }
}

# IAM ロール
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM ロールにポリシーをアタッチ
resource "aws_iam_role_policy" "ecs_task_execution_inline" {
  name   = "ecsTaskExecutionInlinePolicy"
  role   = aws_iam_role.ecs_task_execution.name
  policy = data.aws_iam_policy_document.ecs_task_execution.json
}

resource "aws_ecs_task_definition" "example" {
  family                   = "example"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./container_definition.json")
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
}
