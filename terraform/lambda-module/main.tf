//=================================================================================
# --------------------------- Lambda Function -------------------------------------
//=================================================================================
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/../../lambda_function.py"
  output_path = "${path.module}/../../lambda_function.zip"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  # Alternative way, you can upload the .zip file to s3 bucket.
  # s3_bucket = ""
  # s3_key    = "requests_library.zip"
  filename   = "${path.module}/../../requests_library.zip"
  
  layer_name = "requests_library_layer"
  compatible_runtimes = ["python3.10"]
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.Search_for_Jobs.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.eventbridge_rule_arn
}

resource "aws_lambda_function" "Search_for_Jobs" {
  filename      = "${path.module}/../../lambda_function.zip"
  function_name = "Search_for_Jobs"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256
  layers = [aws_lambda_layer_version.lambda_layer.arn]
  runtime = "python3.10"

  environment {
    variables = {
      dynamodb_table_name = var.dynamodb_table_name,
      job_title = var.job_title,
      sender_email = var.sender_email,
      receiver_email = var.receiver_email
    }
  }
}


//=================================================================================
# --------------------------- Lambda IAM Resources --------------------------------
//=================================================================================
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "Basic_Lambda_CloudWatch_Policy" {    
  statement {
      effect = "Allow"
      
      actions = [
      "logs:CreateLogGroup"
      ]

      resources = ["arn:aws:logs:${var.region}:${var.account_id}:*"]
  }
  statement {
      effect = "Allow"
      
      actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
      ]

      resources = ["arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/Search_for_Jobs:*"]
  }
}

data "aws_iam_policy_document" "Allow_SES" {    
    statement {
        sid = "SESPermissions"
        effect = "Allow"
        actions = [
            "ses:sendEmail"
        ]
        resources = [ "*" ]
    }
}

data "aws_iam_policy_document" "Allow_DynamoDB" {    
  statement {
      effect = "Allow"
      actions = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
      ]
      resources = [ "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${var.dynamodb_table_name}"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name = "Basic_Lambda_CloudWatch_Policy"
    policy = data.aws_iam_policy_document.Basic_Lambda_CloudWatch_Policy.json
  }

  inline_policy {
    name = "Allow-SES-to-Send-Emails-Only-Policy-2"
    policy = data.aws_iam_policy_document.Allow_SES.json
  }

  inline_policy {
    name = "Update-Count-Devops-Jobs-Policy-2"
    policy = data.aws_iam_policy_document.Allow_DynamoDB.json
  }
}