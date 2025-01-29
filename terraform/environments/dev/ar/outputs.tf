output "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB"
  value       = module.dynamodb_table.table_name
}

output "lambda_arn" {
  description = "ARN de la función Lambda"
  value       = module.lambda_create_contact.lambda_function_arn
}

output "api_gateway_url" {
  description = "URL de invocación del API Gateway"
  value       = module.api_gateway.invoke_url
}

output "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito"
  value       = module.cognito.user_pool_id
  sensitive   = true
}