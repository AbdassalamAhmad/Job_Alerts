// =============================================================
# ----------------------- SES Variables ------------------------
// =============================================================

variable "sender_email" {
  description = "sender email for SES"
  type        = string
}

variable "receiver_email" {
  description = "receiver email for SES"
  type        = string
}

// =============================================================
# ---------------- DynamoDb Variables --------------------------
// =============================================================

variable "dynamodb_table_name" {
  type = string
}

// =============================================================
# ---------------- EventBridge Variables -----------------------
// =============================================================

variable "cron_expression" {
  type = string
}

// =============================================================
# --------------------- Lambda Variables -----------------------
// =============================================================

# region is used also in provider.tf
variable "region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "job_title" {
  description = "The Job Title you're looking for like devops or system engineer"
  type        = string
}

# These variables are referenced in dynamodb & SES sections above.
# Because they have the same names.
# dynamodb_table_name
# sender_email
# receiver_email