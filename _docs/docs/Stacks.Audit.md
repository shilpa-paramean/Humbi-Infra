# Audit

This stack does not require any other stack.

This stack applies to AWS accounts of the **audit** type.

## Terraform Workspaces

One terraform workspace AWS Region should be defined for this stack.

The workspace names are the region names.

## Features

### SecurityHub

Enables SecurityHub and collect logs from member accounts defined.

### Auditor IAM Role

Deploys a role called Auditor that have limited access to the account allowing assigned auditors to view logs and compliance reports.

### GuardDuty

Enables GuardDuty.

### Log Buckets

Creates S3 Buckets to receive logs from other accounts.

### Chatbot

Enables AWS Chatbot.

### Notifications

Creates an SNS Topic and allow defined AWS accounts to send notifications to it.

The notifications are then sent to the email and/or slack endpoint defined.

### Access Logs Bucket

Creates S3 Buckets specific for ALB Access Logs and allows other accounts to send logs to.