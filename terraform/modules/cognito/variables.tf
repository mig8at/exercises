variable "user_pool_name" {
  description = "Nombre del User Pool de Cognito"
  type        = string
}

variable "client_name" {
  description = "Nombre del cliente de Cognito"
  type        = string
}

variable "api_gateway_id" {
  description = "ID del API Gateway"
  type        = string
}

variable "region" {
  description = "Región de AWS"
  type        = string
}