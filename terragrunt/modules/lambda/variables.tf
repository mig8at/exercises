# Define input variables
variable "function_name" {
  type = string
}

variable "country" {
  type = string
}

variable "product" {
  type = string
}

variable "environment" {
  type = string
}

variable "filename" {
  type = string
}

variable "memory_size" {
  type = number
}

variable "timeout" {
  type = number
}

variable "enable_dynamodb_access" {
  type    = bool
  default = false
}

variable "dynamodb_actions" {
  type    = list(string)
  default = []
}

variable "dynamodb_table_arn" {
  type    = string
  default = null
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "enable_sns_access" {
  type    = bool
  default = false
}

variable "sns_topic_arn" {
  type    = string
  default = null
}

variable "log_retention_days" {
  type    = number
  default = 7
}

variable "tags" {
  type = map(string)
}
