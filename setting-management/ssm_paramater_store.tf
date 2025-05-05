resource "aws_ssm_parameter" "db_username" {
  name        = "/db/username"
  value       = "root"
  type        = "String"
  description = "User of DB"
}

resource "aws_ssm_parameter" "db_raw_password" {
  name        = "/db/username"
  value       = "VeryStrongPassword"
  type        = "SecureString"
  description = "Password of DB"
}
