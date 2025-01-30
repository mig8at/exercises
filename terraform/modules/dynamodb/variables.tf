variable "table_name" {
  description = "Nombre de la tabla DynamoDB"
  type        = string
}

variable "billing_mode" {
  description = "Modo de facturación (PAY_PER_REQUEST o PROVISIONED)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "Clave primaria de la tabla"
  type        = string
}

variable "stream_enabled" {
  description = "Habilitar DynamoDB Stream"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Tipo de vista del stream (NEW_IMAGE, OLD_IMAGE, etc.)"
  type        = string
  default     = "NEW_IMAGE"
}

