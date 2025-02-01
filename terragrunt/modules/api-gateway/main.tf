resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.country}-${var.product}-${var.environment}-${var.api_name}"
  protocol_type = "HTTP"
  tags          = var.tags
}

output "api_id" {
  value = aws_apigatewayv2_api.http_api.id
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}

output "api_execution_arn" {
  value = aws_apigatewayv2_api.http_api.execution_arn
}

output "api_name" {
  value = aws_apigatewayv2_api.http_api.name
}