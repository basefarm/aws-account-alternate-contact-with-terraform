variable "management_account_id" {
  type        = string
  description = "The account ID of the AWS Organizations Management account, optional if standalone"
  default     = ""
}

locals {
  management_account_id = var.standalone ? data.aws_caller_identity.this.account_id : var.management_account_id
}

# The contact objects (primary, billing, security and operations) are
# all based on the API names for the keys
variable "primary_contact" {
  description = "Primary contact information"
  type = object({
    AddressLine1  = string
    City          = string
    CompanyName   = string
    CountryCode   = string
    PhoneNumber   = string
    PostalCode    = string
    StateOrRegion = string
    WebsiteUrl    = string

  })
  default = {
    AddressLine1  = "Postboks 4488 Nydalen"
    City          = "Oslo"
    CompanyName   = "Orange Business Services AS"
    CountryCode   = "NO"
    PhoneNumber   = "+47 4000 4100"
    PostalCode    = "0403"
    StateOrRegion = "Oslo"
    WebsiteUrl    = "https://cloud.orange-business.com/no/"
  }
}
variable "billing_alternate_contact" {
  description = "The billing alternate contact details."
  type = object({
    Name                 = string
    Title                = string
    EmailAddress         = string
    PhoneNumber          = string
    AlternateContactType = string
  })
  default = {
    Name                 = "Finance Department"
    Title                = "Finance Team"
    EmailAddress         = "aws-billing@basefarm.com"
    PhoneNumber          = "+47 4000 4100"
    AlternateContactType = "BILLING"
  }
}

variable "operations_alternate_contact" {
  description = "The operations alternate contact details."
  type = object({
    Name                 = string
    Title                = string
    EmailAddress         = string
    PhoneNumber          = string
    AlternateContactType = string

  })
  default = {
    Name                 = "Operations Center"
    Title                = "Operations Center"
    EmailAddress         = "support@basefarm-orange.com"
    PhoneNumber          = "+47 4001 3123"
    AlternateContactType = "OPERATIONS"

  }
}

variable "security_alternate_contact" {
  description = "The security alternate contact details."
  type = object({
    Name                 = string
    Title                = string
    EmailAddress         = string
    PhoneNumber          = string
    AlternateContactType = string

  })
  default = {
    Name                 = "Operations Center"
    Title                = "Operations Center"
    EmailAddress         = "support@basefarm-orange.com"
    PhoneNumber          = "+47 4001 3123"
    AlternateContactType = "SECURITY"

  }
}

variable "alternate_contact_role" {
  type        = string
  description = "The AWS IAM role name that will be given to the AWS Lambda execution role."
  default     = "aws-alternate-contact-iam-role"
}

variable "alternate_contact_policy" {
  type        = string
  description = "The name that will be given to the Lambda execution IAM policy."
  default     = "aws-alternate-contact-iam-policy"
}

variable "lambda_function_name" {
  type        = string
  description = "The name of the AWS Lambda function"
  default     = "aws-alternate-contact"
}

variable "log_group_retention" {
  type        = number
  description = <<-EOT
  The number of days you want to retain log events in the specified log group. 
  Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0
  If you select 0, the events in the log group are always retained and never expire.
  EOT
  default     = 731
}

variable "reserved_concurrent_executions" {
  description = "The amount of reserved concurrent executions for this Lambda Function. A value of 0 disables Lambda Function from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1."
  type        = number
  default     = -1
}

variable "event_rule_name" {
  type        = string
  description = "The name of the EventBridge Rule to trigger the AWS Lambda function"
  default     = "aws-alternate-contact-rule"
}

variable "event_rule_description" {
  type        = string
  description = "The description of the EventBridge rule"
  default     = "EventBridge rule to trigger the alternate contact Lambda function"
}

variable "standalone" {
  description = "Standalone deployment, no delegated admin account"
  type        = bool
  default     = true
}

variable "aws_alternate_contact_bus" {
  type        = string
  description = "The name of the custom event bus"
  default     = "aws-alternate-contact"
}

variable "invoke_lambda" {
  description = "Controls if Lambda function should be invoked"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

locals {
  billing_alternate_contact    = jsonencode(var.billing_alternate_contact)
  operations_alternate_contact = jsonencode(var.operations_alternate_contact)
  security_alternate_contact   = jsonencode(var.security_alternate_contact)
  primary_contact              = jsonencode(var.primary_contact)
}
