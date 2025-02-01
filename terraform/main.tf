terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  common_tags = {
    Product     = var.product
    Environment = var.environment
    Terraform   = "true"
  }
}

# Tabla DynamoDB
module "contacts_table" {
  source           = "./modules/dynamodb"
  table_name       = "contacts"
  country          = var.country
  product          = var.product
  environment      = var.environment
  billing_mode     = var.billing_mode
  hash_key         = var.hash_key
  stream_enabled   = true
  stream_view_type = var.stream_view_type
  tags             = local.common_tags
}

# API Gateway
module "main_api" {
  source      = "./modules/api-gateway"
  api_name    = "contacts"
  country     = var.country
  product     = var.product
  environment = var.environment
  tags        = local.common_tags
}

# SNS
module "sns_topic" {
  source      = "./modules/sns"
  topic_name  = "contacts"
  country     = var.country
  product     = var.product
  environment = var.environment
  tags        = local.common_tags
}

# Cognito
module "cognito" {
  source         = "./modules/cognito"
  user_pool_name = "${var.country}-${var.product}-${var.environment}-user-pool"
  client_name    = "${var.country}-${var.product}-${var.environment}-client"
  api_gateway_id = module.main_api.api_id
  region         = var.region
  tags        = local.common_tags
  environment    = var.environment
}

# Lambda Functions
module "create_contact_lambda" {
  source                 = "./modules/lambda"
  function_name          = "create-contact"
  country                = var.country
  product                = var.product
  environment            = var.environment
  filename               = "./../bin/create-contact.zip"
  memory_size            = var.lambda_memory_size
  timeout                = var.lambda_timeout
  enable_dynamodb_access = true
  dynamodb_actions       = ["dynamodb:PutItem"]
  dynamodb_table_arn     = module.contacts_table.table_arn
  environment_variables = {
    TABLE_NAME = module.contacts_table.table_name
  }
  tags = local.common_tags
}

module "dynamodb_trigger_lambda" {
  source                 = "./modules/lambda"
  function_name          = "dynamodb-trigger"
  country                = var.country
  product                = var.product
  environment            = var.environment
  filename               = "./../bin/dynamodb-trigger.zip"
  memory_size            = var.lambda_memory_size
  timeout                = var.lambda_timeout
  enable_dynamodb_access = true
  dynamodb_actions = [
    "dynamodb:GetRecords",
    "dynamodb:GetShardIterator",
    "dynamodb:DescribeStream",
    "dynamodb:ListStreams"
  ]
  # Correct the ARN to use the stream's ARN
  dynamodb_table_arn = module.contacts_table.table_stream_arn
  enable_sns_access  = true
  sns_topic_arn      = module.sns_topic.topic_arn
  environment_variables = {
    TABLE_NAME    = module.contacts_table.table_name
    SNS_TOPIC_ARN = module.sns_topic.topic_arn
  }
  tags = local.common_tags
}

module "get_contact_lambda" {
  source                 = "./modules/lambda"
  function_name          = "get-contact"
  country                = var.country
  product                = var.product
  environment            = var.environment
  filename               = "./../bin/get-contact.zip"
  memory_size            = var.lambda_memory_size
  timeout                = var.lambda_timeout
  enable_dynamodb_access = true
  dynamodb_actions       = ["dynamodb:GetItem"]
  dynamodb_table_arn     = module.contacts_table.table_arn
  environment_variables = {
    TABLE_NAME = module.contacts_table.table_name
  }
  tags = local.common_tags
}

module "sns_trigger_lambda" {
  source                 = "./modules/lambda"
  function_name          = "sns-trigger"
  country                = var.country
  product                = var.product
  environment            = var.environment
  filename               = "./../bin/sns-trigger.zip"
  memory_size            = var.lambda_memory_size
  timeout                = var.lambda_timeout
  enable_dynamodb_access = true
  dynamodb_actions       = ["dynamodb:UpdateItem"]
  dynamodb_table_arn     = module.contacts_table.table_arn
  environment_variables = {
    TABLE_NAME = module.contacts_table.table_name
  }
  tags = local.common_tags
}

# API Gateway Integrations and Routes for /contacts
resource "aws_apigatewayv2_integration" "create_contact_integration" {
  api_id           = module.main_api.api_id
  integration_type = "AWS_PROXY"
  integration_uri  = module.create_contact_lambda.function_arn
}

resource "aws_apigatewayv2_route" "create_contact" {
  api_id    = module.main_api.api_id
  route_key = "POST /contacts"
  target    = "integrations/${aws_apigatewayv2_integration.create_contact_integration.id}"
  # authorizer_id = module.cognito.authorizer_id
}

resource "aws_lambda_permission" "api_gw_create_contact" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.create_contact_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.main_api.api_execution_arn}/${aws_apigatewayv2_stage.default_stage.name}/POST/contacts"
}


resource "aws_apigatewayv2_integration" "get_contact_integration" {
  api_id           = module.main_api.api_id
  integration_type = "AWS_PROXY"
  integration_uri  = module.get_contact_lambda.function_arn
}


resource "aws_apigatewayv2_route" "get_contact" {
  api_id    = module.main_api.api_id
  route_key = "GET /contacts/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.get_contact_integration.id}"
}

resource "aws_lambda_permission" "api_gw_get_contact" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.get_contact_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    =  "${module.main_api.api_execution_arn}/${aws_apigatewayv2_stage.default_stage.name}/GET/contacts/*"
}



# DynamoDB Stream Trigger
resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn  = module.contacts_table.table_stream_arn
  function_name     = module.dynamodb_trigger_lambda.function_arn
  starting_position = "LATEST"
}

#SNS Trigger
resource "aws_sns_topic_subscription" "sns_trigger_sub" {
  topic_arn = module.sns_topic.topic_arn
  protocol  = "lambda"
  endpoint  = module.sns_trigger_lambda.function_arn
}

# Permiso para SNS invocar Lambda
resource "aws_lambda_permission" "sns_trigger" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.sns_trigger_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = module.sns_topic.topic_arn
}


resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id = module.main_api.api_id
  depends_on = [
    aws_apigatewayv2_route.create_contact,
    aws_apigatewayv2_route.get_contact,
    aws_apigatewayv2_stage.default_stage
  ]
}


resource "aws_cloudwatch_log_group" "api_gw_access_logs" {
  name              = "/aws/apigateway/${module.main_api.api_name}-access"
  retention_in_days = var.log_retention_days
  tags              = local.common_tags
}

# Stage para el entorno (requerido para la URL)
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = module.main_api.api_id
  name        = var.environment
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_access_logs.arn
    format = jsonencode({
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

  tags = local.common_tags
  # Asegúrate de que el grupo de logs se cree primero
  depends_on = [aws_cloudwatch_log_group.api_gw_access_logs]
}
