resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.country}-${var.product}-${var.environment}-${var.api_name}"
  protocol_type = "HTTP"
  tags          = var.tags
}

# Integraciones
resource "aws_apigatewayv2_integration" "create_contact_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.create_contact_lambda_arn
}

resource "aws_apigatewayv2_integration" "get_contact_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.get_contact_lambda_arn
}

# Rutas
resource "aws_apigatewayv2_route" "create_contact" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /contacts"
  target    = "integrations/${aws_apigatewayv2_integration.create_contact_integration.id}"
}

resource "aws_apigatewayv2_route" "get_contact" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /contacts/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.get_contact_integration.id}"
}

# Logs
resource "aws_cloudwatch_log_group" "api_gw_access_logs" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.http_api.name}-access"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

# Stage
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = var.environment
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_access_logs.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      responseLength = "$context.responseLength"
      errorMessage   = "$context.integrationErrorMessage"
    })
  }

  tags = var.tags
  depends_on = [aws_cloudwatch_log_group.api_gw_access_logs]
}

# Deployment
resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id = aws_apigatewayv2_api.http_api.id
  depends_on = [
    aws_apigatewayv2_route.create_contact,
    aws_apigatewayv2_route.get_contact,
    aws_apigatewayv2_stage.default_stage
  ]
}

# Outputs
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