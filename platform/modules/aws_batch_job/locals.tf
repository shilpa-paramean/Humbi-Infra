
#locals {
#    job_name           = var.job_name
#    job_role_arn       = var.job_role_arn
#    execution_role_arn = var.execution_role_arn
#    image              = var.image
#    memory             = var.memory
#    vcpu               = var.vcpu
#
#}

locals {
  job_name           = var.job_name

  attributes = {
    image = var.image
    command = [
      "/bin/bash",
      "-c",
      "cd /opt && yum -y install unzip  && curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\" && unzip awscliv2.zip && ./aws/install && aws s3 cp s3://$INPUT ./input.zip && unzip -d input input.zip && aws s3 cp ./input s3://$OUTPUT/$(date +%s)/ --recursive && aws s3 cp s3://$INPUT s3://$ARCHIVE --storage-class GLACIER && aws s3 rm s3://$INPUT"
    ]
    jobRoleArn = var.job_role_arn
    executionRoleArn = var.execution_role_arn
    resourceRequirements =  [
      { 
        type = "VCPU"
        value = tostring(var.vcpu)
      },
      {
        type = "MEMORY"
        value = tostring(var.memory)
      }
    ]
  }
}


