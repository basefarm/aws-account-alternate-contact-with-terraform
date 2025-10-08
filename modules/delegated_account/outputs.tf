output "delegated_account_bus" {
  value       = var.standalone ? "NA" : aws_cloudwatch_event_bus.aws_alternate_contact_bus[0].arn
  description = "The ARN of the custom event bus in the delegated account"
}

output "event_rule_cross_account" {
  value       = aws_cloudwatch_event_rule.event_rule_cross_account.arn
  description = "The Amazon Resource Name (ARN) of the EventBridge rule"
}

output "alternate_contact_role" {
  value       = aws_iam_role.alternate_contact_role.arn
  description = "The Amazon Resource Name (ARN) specifying the Lambda IAM role"
}

output "aws_lambda_function" {
  value       = aws_lambda_function.alternate_contact_lambda.arn
  description = "The Amazon Resource Name (ARN) identifying the Lambda Function"
}

output "failed_accounts" {
  description = "List of accounts where lambda execution failed"
  value = jsondecode(data.aws_lambda_invocation.run[0].result)
}
