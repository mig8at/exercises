locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//api-gateway"
}

inputs = {
  api_name    = "contacts"
  tags        = local.common_vars.locals.common_tags

  # Log configuration
  enable_access_logs = true
  log_format = jsonencode({
    requestId      = "$context.requestId"
    ip             = "$context.identity.sourceIp"
    requestTime    = "$context.requestTime"
    httpMethod     = "$context.httpMethod"
    routeKey       = "$context.routeKey"
    status         = "$context.status"
    responseLength = "$context.responseLength"
    errorMessage   = "$context.integrationErrorMessage"
  })
}