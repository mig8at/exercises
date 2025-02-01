variable "region" {
  type = string
}

variable "user_pool_name" {
  type = string
}

variable "client_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "api_gateway_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
