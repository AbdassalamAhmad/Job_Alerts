module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  create_bus = false

# the name of the event will be crons-rule
  rules = {
    crons = {
      description         = "Trigger for a Lambda"
      schedule_expression = var.cron_expression
    }
  }

  targets = {
    crons = [
      {
        name  = "lambda-loves-cron" # didn't found it in the cosnole, but it's necessary for this module to work.
        arn   = var.lambda_arn
      }
    ]
  }
}