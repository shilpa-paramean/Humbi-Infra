
resource "aws_iam_role" "aws_batch_service_role" {
  name = "aws_batch_service_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
        "Service": "batch.amazonaws.com"
        }
    }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws_batch_service_role" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}


resource "aws_security_group" "sg" {
  name = "aws_batch_compute_environment_security_group"
  vpc_id = local.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}





resource "aws_batch_compute_environment" "batch_env" {
  compute_environment_name = local.name

  compute_resources {
    #allocation_strategy = "SPOT_CAPACITY_OPTIMIZED"

    max_vcpus = 16
    #min_vcpus = 0

    security_group_ids = [
      aws_security_group.sg.id,
    ]

    subnets = local.subnet_ids
    type = "FARGATE"
  }

  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.aws_batch_service_role]
}

resource "aws_batch_job_queue" "hh_processing_queue" {
  name     = "hh-processing-queue"
  state    = "ENABLED"
  priority = 1
  compute_environments = [
    aws_batch_compute_environment.batch_env.arn
  ]
}

resource "aws_iam_role" "hh_batchjob_role" {
  name = "hh_batchjob_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["ec2.amazonaws.com", "lambda.amazonaws.com", "ecs-tasks.amazonaws.com"]
        }
      },
    ]
  })

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.

}

resource "aws_iam_policy" "hh_batchjob_policy" {
  name = "hh_batchjob_policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:CreateTags",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": "RunInstances"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ecs:StartTask",
                "ecs:DescribeTaskDefinition",
                "logs:CreateLogStream",
                "ec2:ModifySpotFleetRequest",
                "autoscaling:DescribeAutoScalingGroups",
                "ecs:RegisterTaskDefinition",
                "ec2:DescribeAccountAttributes",
                "autoscaling:UpdateAutoScalingGroup",
                "ecs:StopTask",
                "ecs:DeregisterContainerInstance",
                "ec2:DescribeKeyPairs",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ecs:ListTaskDefinitions",
                "autoscaling:PutNotificationConfiguration",
                "iam:GetRole",
                "autoscaling:SetDesiredCapacity",
                "ecs:CreateCluster",
                "ecs:DeleteCluster",
                "ec2:RunInstances",
                "autoscaling:SuspendProcesses",
                "logs:CreateLogGroup",
                "ec2:DescribeVpcClassicLink",
                "ecs:DescribeClusters",
                "autoscaling:CreateOrUpdateTags",
                "ec2:DescribeImageAttribute",
                "ecs:ListContainerInstances",
                "autoscaling:DeleteAutoScalingGroup",
                "ec2:DescribeSubnets",
                "autoscaling:CreateAutoScalingGroup",
                "autoscaling:DescribeAutoScalingInstances",
                "ec2:CancelSpotFleetRequests",
                "ec2:DescribeInstanceAttribute",
                "autoscaling:DescribeLaunchConfigurations",
                "ec2:RequestSpotFleet",
                "ec2:DescribeSpotInstanceRequests",
                "ecs:DeregisterTaskDefinition",
                "ec2:DescribeSpotPriceHistory",
                "ecs:RunTask",
                "ecs:ListTasks",
                "autoscaling:DescribeAccountLimits",
                "ecs:DescribeContainerInstances",
                "ecs:DescribeTasks",
                "ecs:ListClusters",
                "ec2:DeleteLaunchTemplate",
                "ec2:TerminateInstances",
                "iam:GetInstanceProfile",
                "logs:DescribeLogGroups",
                "ec2:DescribeLaunchTemplateVersions",
                "logs:PutLogEvents",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSpotFleetRequests",
                "ec2:DescribeImages",
                "autoscaling:CreateLaunchConfiguration",
                "ecs:ListAccountSettings",
                "ec2:DescribeSpotFleetInstances",
                "ec2:CreateLaunchTemplate",
                "autoscaling:DeleteLaunchConfiguration",
                "ecs:ListTaskDefinitionFamilies",
                "kms:GenerateDataKey",
                "ecs:UpdateContainerAgent"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ecs:TagResource",
            "Resource": "arn:aws:ecs:*:*:task/*_Batch_*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": [
                        "ec2.amazonaws.com",
                        "ec2.amazonaws.com.cn",
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "spot.amazonaws.com",
                        "spotfleet.amazonaws.com",
                        "autoscaling.amazonaws.com",
                        "ecs.amazonaws.com"
                    ]
                }
            }
        }

    ]
})

}

resource "aws_iam_role_policy_attachment" "batchjob_policy_attachment" {
  role       = aws_iam_role.hh_batchjob_role.name
  policy_arn = aws_iam_policy.hh_batchjob_policy.arn
}


resource "aws_iam_role_policy_attachment" "s3_attachment" {
  role       = aws_iam_role.hh_batchjob_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_attachment" {
  role       = aws_iam_role.hh_batchjob_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}






