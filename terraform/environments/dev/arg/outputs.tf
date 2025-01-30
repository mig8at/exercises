# environments/dev/ar/outputs.tf (nuevo archivo)
output "api_base_url" {
  value = module.main_api.api_endpoint
}

output "create_contact_url" {
  value = "${module.main_api.api_endpoint}/contacts"
}

output "get_contact_url" {
  value = "${module.main_api.api_endpoint}/contacts/{id}"
}
