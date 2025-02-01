locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//cognito"
}

dependency "api_gateway" {
  config_path = "../api-gateway"

  mock_outputs = {
    api_id = "test-api-id"
  }
}

inputs = {
  tags            = local.common_vars.locals.common_tags
  api_gateway_id  = dependency.api_gateway.outputs.api_id
  
  # These will be prefixed with country and environment
  user_pool_name = "user-pool"
  client_name    = "client"
}