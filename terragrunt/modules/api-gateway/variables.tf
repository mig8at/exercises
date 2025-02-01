variable "country" {
  description = "Country code"
  type        = string
}

variable "product" {
  description = "Product name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "api_name" {
  description = "Name of the API"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
}

variable "create_contact_lambda_arn" {
  description = "ARN of the create contact Lambda function"
  type        = string
}

variable "get_contact_lambda_arn" {
  description = "ARN of the get contact Lambda function"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain API Gateway logs"
  type        = number
  default     = 7
}