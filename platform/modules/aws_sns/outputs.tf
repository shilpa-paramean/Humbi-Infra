output "sns_topic_arn" {
  description = "The ARN of the SNS topic"
  value = element(
    concat(
      aws_sns_topic.this.*.arn,
      [""],
    ),
    0,
  )
}

