# Baseline

This stack requires the following stacks:

* Audit

This stack applies to AWS accounts of the **workload** and **audit** types.

## Terraform Workspaces

One terraform workspace per AWS Account and Region should be defined for this stack.

The workspace name is the account name plus region.

Example, if you have a workload account called "staging" in 2 regions, the workspaces for this stack (and, for this account alone) should be:

* staging-ap-southeast-2-default
* staging-us-east-1-default

## Features

### CloudTrail

Enables CloudTrail in the AWS account, with the option to alarm on common detections like lack of MFA and root login.

### GuardDuty

Enables GuardDuty.

### SecurityHub

Enables SecurityHub.

### Config

Enables AWS Config.

### ECS Encryption Policy

Sets a policy for EBS volumes in the account to come with encryption by default.