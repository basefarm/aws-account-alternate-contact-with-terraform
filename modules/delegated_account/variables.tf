variable "management_account_id" {
  type        = string
  description = "The account ID of the AWS Organizations Management account, optional if standalone"
  default     = ""
}

locals {
  management_account_id = var.standalone ? data.aws_caller_identity.this.account_id : var.management_account_id
}

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
  description = "The alternate contact details."
  type = object({
    name          = string
    title         = string
    email_address = string
    phone_number  = string
  })
  default = {
    name          = "Finance Department"
    title         = "Finance Team"
    email_address = "aws-billing@basefarm.com"
    phone_number  = "+47 4000 4100"
  }
}

variable "operations_alternate_contact" {
  description = "The alternate contact details."
  type = object({
    name          = string
    title         = string
    email_address = string
    phone_number  = string
  })
  default = {
    name          = "Operations Center"
    title         = "Operations Center"
    email_address = "support@basefarm-orange.com"
    phone_number  = "+47 4001 3123"
  }
}

variable "security_alternate_contact" {
  description = "The security alternate contact details."
  type = object({
    name          = string
    title         = string
    email_address = string
    phone_number  = string
  })
  default = {
    name          = "Operations Center"
    title         = "Operations Center"
    email_address = "support@basefarm-orange.com"
    phone_number  = "+47 4001 3123"
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
  default     = 60
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
  billing_alternate_contact = format(
    "CONTACT_TYPE=BILLING; EMAIL_ADDRESS=%s; CONTACT_NAME=%s; PHONE_NUMBER=%s; CONTACT_TITLE=%s",
    var.billing_alternate_contact.email_address,
    var.billing_alternate_contact.name,
    var.billing_alternate_contact.phone_number,
    var.billing_alternate_contact.title
  )
  operations_alternate_contact = format(
    "CONTACT_TYPE=OPERATIONS; EMAIL_ADDRESS=%s; CONTACT_NAME=%s; PHONE_NUMBER=%s; CONTACT_TITLE=%s",
    var.operations_alternate_contact.email_address,
    var.operations_alternate_contact.name,
    var.operations_alternate_contact.phone_number,
    var.operations_alternate_contact.title
  )
  security_alternate_contact = format(
    "CONTACT_TYPE=SECURITY; EMAIL_ADDRESS=%s; CONTACT_NAME=%s; PHONE_NUMBER=%s; CONTACT_TITLE=%s",
    var.security_alternate_contact.email_address,
    var.security_alternate_contact.name,
    var.security_alternate_contact.phone_number,
    var.security_alternate_contact.title
  )
  primary_contact = jsonencode(var.primary_contact)
}
