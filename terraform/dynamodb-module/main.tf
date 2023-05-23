resource "aws_dynamodb_table" "dynamodb_table" {
  name           = var.dynamodb_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "Company-Name"

  attribute {
    name = "Company-Name"
    type = "S"
  }
}