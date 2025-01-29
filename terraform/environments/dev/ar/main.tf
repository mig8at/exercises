module "dynamodb_table" {
  source       = "../../../modules/dynamodb"
  table_name   = "dev-ar-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  tags = {
    Environment = "dev"
    Country     = "ar"
  }
}

module "lambda_create_contact" {
  source                = "../../../modules/lambda"
  filename              = "../../../../lambdas/create-contact/main.zip"
  function_name         = "create-contact-dev-ar"
  runtime               = "provided.al2"
  architectures         = ["arm64"]
  handler               = "bootstrap"
  environment_variables = {
    TABLE_NAME = module.dynamodb_table.table_name
  }
  dynamodb_table_arn    = module.dynamodb_table.table_arn
}

module "api_gateway" {
  source                 = "../../../modules/api-gateway"
  api_name               = "contacts-api-dev-ar"
  lambda_arn             = module.lambda_create_contact.lambda_function_arn
  lambda_function_name   = module.lambda_create_contact.lambda_function_name
  cognito_authorizer_id  = module.cognito.authorizer_id
}

module "cognito" {
  source          = "../../../modules/cognito"
  user_pool_name  = "dev-ar-users"
  client_name     = "dev-ar-client"
  api_gateway_id  = module.api_gateway.api_id
  region          = "us-east-1"
}