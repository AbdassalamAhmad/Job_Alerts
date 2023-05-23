variable "region" {
  description = "AWS region"
  type = string
}

variable "account_id" {
  description = "AWS account ID"
  type = string
}

variable "dynamodb_table_name" {
  type = string
}

variable "eventbridge_rule_arn" {
  type = string
}

variable "job_title" {
  type = string
}

variable "sender_email" {
  type = string
  sensitive = true
}

variable "receiver_email" {
  type = string
  sensitive = true
}

