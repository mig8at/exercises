variable "api_name" {
  description = "Nombre del API Gateway"
  type        = string
}

variable "lambda_arn" {
  description = "ARN de la función Lambda"
  type        = string
}

variable "lambda_function_name" {
  description = "Nombre de la función Lambda"
  type        = string
}

variable "cognito_authorizer_id" {
  description = "ID del autorizador de Cognito"
  type        = string
}