# Tabla DynamoDB
resource "aws_dynamodb_table" "this" {
  name         = "${var.country}-${var.product}-${var.environment}-${var.table_name}"
  billing_mode = var.billing_mode
  hash_key     = var.hash_key

  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_view_type

  attribute {
    name = var.hash_key
    type = "S"
  }
}

# Outputs

output "table_name" {
  value = aws_dynamodb_table.this.name
}

output "table_arn" {
  value = aws_dynamodb_table.this.arn
}

output "table_stream_arn" {
  value = aws_dynamodb_table.this.stream_arn
}