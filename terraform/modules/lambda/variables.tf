variable "filename" {
  description = "The path to the Lambda function deployment package"
  type        = string
}

variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "runtime" {
  description = "The runtime environment for the Lambda function"
  type        = string
}

variable "architectures" {
  description = "The architecture of the Lambda function"
  type        = list(string)
}

variable "handler" {
  description = "The function entrypoint in your code"
  type        = string
}

variable "environment_variables" {
  description = "A map of environment variables to pass to the Lambda function"
  type        = map(string)
}

variable "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table"
  type        = string
}