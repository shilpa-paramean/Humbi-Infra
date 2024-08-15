resource "aws_sns_topic" "this" {
  count = var.create ? 1 : 0

  name        = var.name
  kms_master_key_id = "alias/aws/sns"
  application_success_feedback_role_arn = aws_iam_role.success_role.arn
  application_failure_feedback_role_arn = aws_iam_role.failure_role.arn
  tags = var.tags
}

resource "aws_iam_role" "success_role" {
  name = substr("SNSDeliverySuccessRole-${var.name}",0,64)

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "sns.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })

  inline_policy {
    name = "cw_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:PutMetricFilter",
            "logs:PutRetentionPolicy"
           ],
          "Resource": [
            "*"
          ]
      }
    ]
    })
  }
  
}

resource "aws_iam_role" "failure_role" {
  name = substr("SNSDeliveryFailureRole-${var.name}", 0 ,64)

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "sns.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })

  inline_policy {
    name = "cw_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:PutMetricFilter",
            "logs:PutRetentionPolicy"
           ],
          "Resource": [
            "*"
          ]
      }
    ]
    })
  }
  
}
