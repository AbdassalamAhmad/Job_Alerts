module "eventbridge" {
  source          = "./eventbridge-module/"
  cron_expression = var.cron_expression
  lambda_arn      = module.lambda.lambda_function_arn
}

module "lambda" {
  source               = "./lambda-module/"
  region               = var.region
  account_id           = var.account_id
  dynamodb_table_name  = var.dynamodb_table_name
  job_title            = var.job_title
  sender_email         = var.sender_email
  receiver_email       = var.receiver_email
  eventbridge_rule_arn = "arn:aws:events:${var.region}:${var.account_id}:rule/crons-rule"
}

module "dynamodb" {
  source              = "./dynamodb-module/"
  dynamodb_table_name = var.dynamodb_table_name
}