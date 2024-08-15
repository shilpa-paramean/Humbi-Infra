# ----
# MAIN
# ----

resource "aws_iam_role" "lambda_role" {
  name               = join("-", [substr("${local.name}", 1, 59), "role"])
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["apigateway.amazonaws.com", "lambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_lambda_role_step_function_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
}

resource "aws_iam_role_policy_attachment" "iam_lambda_role_dynamo_db_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "iam_lambda_role_ec2_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "iam_lambda_role_ssm_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "iam_lambda_role_sm_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "iam_lambda_role_apigateway_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
}

resource "aws_iam_role_policy_attachment" "iam_lambda_role_sqs_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "iam_lambda_role_cw_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "iam_lambda_role_sns_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}


resource "aws_cloudwatch_log_group" "lambda_logging" {
  name = "/aws/lambda/${local.name}"
}

resource "aws_iam_role_policy" "lambda_cloudwatch_policy" {
  name   = "${local.name}-lambda-cw-policy"
  policy = data.aws_iam_policy_document.cloudwatch_role_policy_document.json
  role   = aws_iam_role.lambda_role.name
}

 resource "aws_security_group" "lambda_sg" {
   name        = "${local.name}-sg"
   description = "${local.name}-sg"
   vpc_id      = local.vpc_id

   ingress {
     description      = "lambda"
     from_port        = 443
     to_port          = 443
     protocol         = "TCP"
     cidr_blocks      = ["0.0.0.0/0"]
     ipv6_cidr_blocks = ["::/0"]
   }

   egress {
     from_port        = 0
     to_port          = 0
     protocol         = "-1"
     cidr_blocks      = ["0.0.0.0/0"]
     ipv6_cidr_blocks = ["::/0"]
   }

   tags = {
     Name = "${local.name}-sg"
   }
 }

resource "aws_lambda_function" "this" {
  filename         = "${path.cwd}/lambdas/${local.filename}"
  function_name    = local.name
  role             = aws_iam_role.lambda_role.arn
  handler          = local.handler
  runtime          = local.runtime
  timeout          = local.timeout
  layers           = local.lambda_layers != null ? local.lambda_layers : []
  source_code_hash = local.lambda_source_code_hash

   vpc_config {
     subnet_ids         = local.private_subnet_ids
     security_group_ids = [aws_security_group.lambda_sg.id]
   }

  environment {
    variables = local.lambda_environment_variables
  }

  depends_on = [
     aws_security_group.lambda_sg,
    aws_cloudwatch_log_group.lambda_logging
  ]
}

