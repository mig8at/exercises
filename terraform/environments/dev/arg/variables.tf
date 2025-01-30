variable "country" {
  description = "El país donde se despliega el recurso"
  type        = string
  default     = "arg"
}

variable "product" {
  description = "El nombre del producto"
  type        = string
  default     = "contacts"
}

variable "environment" {
  description = "El ambiente de despliegue (dev, staging, prod)"
  type        = string
  default     = "dev"
}