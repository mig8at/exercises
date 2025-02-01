locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//lambda"
}

dependency "dynamodb" {
  config_path = "../dynamodb"

  mock_outputs = {
    table_arn = "arn:aws:dynamodb:us-east-1:123456789012:table/mock-table"
    table_name = "mock-table"
    table_stream_arn = "arn:aws:dynamodb:us-east-1:123456789012:table/mock-table/stream/mock-stream"
  }
}

dependency "sns" {
  config_path = "../sns"

  mock_outputs = {
    topic_arn = "arn:aws:sns:us-east-1:123456789012:mock-topic"
  }
}

inputs = {
  tags = local.common_vars.locals.common_tags

  # Common Lambda configurations
  create_contact_lambda = {
    function_name          = "create-contact"
    filename               = "./../bin/create-contact.zip"
    enable_dynamodb_access = true
    dynamodb_actions       = ["dynamodb:PutItem"]
    dynamodb_table_arn     = dependency.dynamodb.outputs.table_arn
    environment_variables = {
      TABLE_NAME = dependency.dynamodb.outputs.table_name
    }
  }

  get_contact_lambda = {
    function_name          = "get-contact"
    filename               = "./../bin/get-contact.zip"
    enable_dynamodb_access = true
    dynamodb_actions       = ["dynamodb:GetItem"]
    dynamodb_table_arn     = dependency.dynamodb.outputs.table_arn
    environment_variables = {
      TABLE_NAME = dependency.dynamodb.outputs.table_name
    }
  }

  dynamodb_trigger_lambda = {
    function_name          = "dynamodb-trigger"
    filename               = "./../bin/dynamodb-trigger.zip"
    enable_dynamodb_access = true
    dynamodb_actions = [
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:DescribeStream",
      "dynamodb:ListStreams"
    ]
    dynamodb_table_arn     = dependency.dynamodb.outputs.table_stream_arn
    enable_sns_access      = true
    sns_topic_arn          = dependency.sns.outputs.topic_arn
    environment_variables = {
      TABLE_NAME    = dependency.dynamodb.outputs.table_name
      SNS_TOPIC_ARN = dependency.sns.outputs.topic_arn
    }
  }

  sns_trigger_lambda = {
    function_name          = "sns-trigger"
    filename               = "./../bin/sns-trigger.zip"
    enable_dynamodb_access = true
    dynamodb_actions       = ["dynamodb:UpdateItem"]
    dynamodb_table_arn     = dependency.dynamodb.outputs.table_arn
    environment_variables = {
      TABLE_NAME = dependency.dynamodb.outputs.table_name
    }
  }
}