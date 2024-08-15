# ---------
# VARIABLES
# ---------

variable "name" {
  type = string
}


variable "region" {
  type = string
}

variable "filename" {
  type = string
}

 variable "private_subnet_ids" {
   type = list(string)
 }

 variable "vpc_id" {
   type = string
 }

variable "lambda_source_code_hash" {
  type = string
}

variable "lambda_environment_variables" {
  type = map(string)
}

variable "runtime" {
  type = string
}

variable "timeout" {
  type = number
}

variable "handler" {
  type = string
}

variable "lambda_layers" {
  type    = list(string)
  default = null
}


