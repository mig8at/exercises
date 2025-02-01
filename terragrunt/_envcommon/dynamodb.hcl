locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//dynamodb"
}

inputs = {
  table_name       = "contacts"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "id"
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
  tags            = local.common_vars.locals.common_tags
}