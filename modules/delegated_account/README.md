# `aws-account-alternate-contact-with-terraform/delegated_account`


## Description

This Terraform module implements a custom Amazon EventBridge event bus, EventBridge Rule, AWS IAM roles, and AWS Lambda function to programmatically configure your alternate contact. The Lambda function obtains a list of accounts in your AWS Organizations and configures the alternate contact across all accounts using the Lambda environment variables supplied as input to the module. You can invoke the Lambda function by setting the `invoke_lambda` variable as `true`.

By default, this module creates a deployment package and uses it to create or update a Lambda Function or Lambda Layer.


## Resources

| Name                            | Type         |
| ---------                       |----          |
| aws_iam_role                    | Resource     |
| aws_iam_policy                  | Resource     |
| aws_lambda_function             | Resource     |
| aws_lambda_permission           | Resource     |
| aws_cloudwatch_log_group        | Resource     |
| aws_cloudwatch_event_bus        | Resource     |
| aws_cloudwatch_event_bus_policy | Resource     |
| aws_cloudwatch_event_rule       | Resource     |
| aws_cloudwatch_event_target     | Resource     |


## Input variables

All variable details can be found in the [variables.tf](./variables.tf) file.

| Variable Name               | Description                                                                      | Type         |  Default                      | Required |
| -------------               | -----------                                                                      | --------     | -----                         |--------  |
| `management_account_id`     | The account ID of the AWS Organizations Management account.                      | `string`     |                               | Not if standalone      |
| `alternate_contact_role`    | The AWS IAM role name that will be given to the AWS Lambda execution role        | `string`     | aws-alternate-contact-iam-role   | No   |
| `alternate_contact_policy`  | The name that will be given to the Lambda execution IAM policy                   | `string`     | aws-alternate-contact-iam-policy | No   |
| `lambda_function_name`      | The name of the AWS Lambda function                                              | `string`     | aws-alternate-contact         | No       |
| `log_group_retention`       | The number of days you want to retain log events in the specified log group      | `number`     | 60                            | No       |
| `reserved_concurrent_executions` | The amount of reserved concurrent executions for this Lambda Function       | `number`     | -1                            | No       |
| `event_rule_name`           | The name of the EventBridge Rule to trigger the AWS Lambda function              | `string`     | aws-alternate-contact-rule    | No       |
| `event_rule_description`    | The description of the EventBridge rule     | `string`     | EventBridge rule to trigger the alternate contact Lambda function  | No       |
| `aws_alternate_contact_bus` | The name of the custom event bus                                                 | `string`     | aws-alternate-contact         | No       |
| `invoke_lambda`             | Controls if Lambda function should be invoked                                    | `bool`       |                               | No       |
| `primary_contact`           | Primary contact information                                                      | `object`     | Company default (see below)   | No       |
| `billing_alternate_contact` | The alternate contact details.                                                   | `object`     | Company default (see below)   | No       |
| `operations_alternate_contact`| The alternate contact details.                                                 | `object`     | Company default (see below)   | No       |
| `security_alternate_contact`| The alternate contact details.                                                   | `object`     | Company default (see below)   | No       |
| `standalone`                | Standalone deployment, no delegated admin account                                | `bool`       | true                          | No       |
| `tags`                      | A map of tags to assign to the resource                                          | `map(string)`|                               | No       |

The `*_alternate_contacts` variables have defined defaults matching the company requirements. If you need to change them, consider changing the module defaults.

| Variable Name                  | Default |
| -------------                  | --------|
| `primary_contact`              | See (./variables.tf) |
| `billing_alternate_contact`    |<pre>{<br>  name          = "Finance Department"<br>  title         = "Finance Team"<br>  email_address = "aws-billing@basefarm.com"<br>  phone_number  = "+47 4000 4100"<br>}</pre>|
| `operations_alternate_contact` |<pre>{<br>  name          = "Operations Center"<br>  title         = "Operations Center"<br>  email_address = "support@basefarm-orange.com"<br>  phone_number  = "+47 4001 3123"<br>}</pre>|
| `security_alternate_contact`   |<pre>{<br>  name          = "Operations Center"<br>  title         = "Operations Center"<br>  email_address = "support@basefarm-orange.com"<br>  phone_number  = "+47 4001 3123"<br>}</pre>|




## Outputs

All output details can be found in [aws-account-alternate-contact-with-terraform/delegated_account/outputs.tf](outputs.tf).

| Variable Name             | Description                                                             |
| -------------             | -----------                                                             |
| `delegated_account_bus`   | The ARN of the custom event bus in the delegated account                |
| `event_rule_cross_account`| The Amazon Resource Name (ARN) of the EventBridge rule                  |
| `alternate_contact_role`  | The Amazon Resource Name (ARN) specifying the Lambda IAM role           |
| `aws_lambda_function`     | The Amazon Resource Name (ARN) identifying the Lambda Function          |
| `failed_accounts`         | List of accounts where lambda execution failed                          |
