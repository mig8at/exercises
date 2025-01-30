# arg-prepaid-dev

# Función Lambda
resource "aws_lambda_function" "this" {
  filename      = var.filename
  function_name = "${var.country}-${var.product}-${var.environment}-${var.function_name}"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "provided.al2"
  handler       = "bootstrap"
  memory_size   = var.memory_size
  architectures = ["arm64"]
  environment {
    variables = var.environment_variables
  }
}

# Rol IAM para Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.country}-${var.product}-${var.environment}-${var.function_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Política de logs (CloudWatch)
resource "aws_iam_role_policy" "logs_policy" {
  name = "${var.country}-${var.product}-${var.environment}-${var.function_name}-logs"
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
      Resource = "*"
    }]
  })
}

# Política para DynamoDB (condicional)
resource "aws_iam_role_policy" "dynamodb_policy" {
  count = var.enable_dynamodb_access ? 1 : 0
  name  = "${var.country}-${var.product}-${var.environment}-${var.function_name}-dynamodb"
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
  name  = "${var.country}-${var.product}-${var.environment}-${var.function_name}-sns"
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