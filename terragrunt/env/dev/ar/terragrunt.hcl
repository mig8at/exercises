include "root" {
  path = find_in_parent_folders()
}

include "dynamodb" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/dynamodb.hcl"
}

include "api-gateway" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/api-gateway.hcl"
}

include "cognito" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/cognito.hcl"
}

include "lambda" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/lambda.hcl"
}

include "sns" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/sns.hcl"
}

inputs = {
  environment = "dev"
  country     = "ar"
  region      = "us-east-1"
  
  lambda_memory_size = 128
  lambda_timeout    = 10
  log_retention_days = 7
}