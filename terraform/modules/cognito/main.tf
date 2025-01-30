


resource "aws_cognito_user_pool" "pool" {
  name = var.user_pool_name
}

resource "aws_cognito_user_pool_client" "client" {
  name            = var.client_name
  user_pool_id    = aws_cognito_user_pool.pool.id
  generate_secret = true
}

resource "aws_apigatewayv2_authorizer" "jwt" {
  api_id           = var.api_gateway_id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"
  jwt_configuration {
    audience = [aws_cognito_user_pool_client.client.id]
    issuer   = "https://cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.pool.id}"
  }
}

# Outputs
output "authorizer_id" {
  value = aws_apigatewayv2_authorizer.jwt.id
}