locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//sns"
}

inputs = {
  topic_name = "contacts"
  tags       = local.common_vars.locals.common_tags
}