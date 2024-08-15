# ---------
# VARIABLES
# ---------

variable "aws_region" {
  type = string
}

variable "name" {
  type = string
}

variable  "job_queue" {
  type = string
}              

variable  "job_definition" {                                       
  type = string
}    
                         

variable "vpc_id" {}

variable "subnet_ids" {}

# variable "send_error_sns_topic_arn" {
#   type = string
# }
