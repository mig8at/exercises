locals {
  prefix = "${var.country}-${var.product}-${var.environment}-${var.function_name}"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.prefix}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
  lifecycle {
    prevent_destroy = false
  }
}

# Función Lambda
resource "aws_lambda_function" "this" {
  filename      = var.filename
  function_name = local.prefix
  role          = aws_iam_role.lambda_role.arn
  runtime       = "provided.al2"
  handler       = "bootstrap"
  memory_size   = var.memory_size
  timeout       = var.timeout
  architectures = ["arm64"]
  environment {
    variables = var.environment_variables
  }

  depends_on = [aws_cloudwatch_log_group.lambda]
  tags       = var.tags
}

# Rol IAM para Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${local.prefix}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

# Política de logs (CloudWatch)
resource "aws_iam_role_policy" "logs_policy" {
  name = "${local.prefix}-logs"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Effect   = "Allow"
      Resource = [
        aws_cloudwatch_log_group.lambda.arn,
        "${aws_cloudwatch_log_group.lambda.arn}:*"
      ]
    }]
  })
}

# Política para DynamoDB (condicional)
resource "aws_iam_role_policy" "dynamodb_policy" {
  count = var.enable_dynamodb_access ? 1 : 0
  name  = "${local.prefix}-dynamodb"
  role  = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = var.dynamodb_actions,
      Resource = [
        var.dynamodb_table_arn,
        "${var.dynamodb_table_arn}/index/*"
      ]
    }]
  })
}

# Política para SNS (condicional)
resource "aws_iam_role_policy" "sns_policy" {
  count = var.enable_sns_access ? 1 : 0
  name  = "${local.prefix}-sns"
  role  = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["sns:Publish"],
      Resource = var.sns_topic_arn
    }]
  })
}

# Outputs
output "function_arn" {
  value = aws_lambda_function.this.arn
}

output "function_name" {
  value = aws_lambda_function.this.function_name
}