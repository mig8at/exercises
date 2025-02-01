locals {
  # Load account and region variables
  environment = path_relative_to_include() =~ "^env/([^/]+).*" ? regex("^env/([^/]+).*", path_relative_to_include())[0] : "dev"
  country     = path_relative_to_include() =~ "^env/[^/]+/([^/]+).*" ? regex("^env/[^/]+/([^/]+).*", path_relative_to_include())[0] : "ar"
  
  # Common tags for all resources
  common_tags = {
    Environment = local.environment
    Country     = local.country
    Product     = "onboarding"
    Terraform   = "true"
  }
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "your-terraform-state-${local.country}-${local.environment}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
}
EOF
}