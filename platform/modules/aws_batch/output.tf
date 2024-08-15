########
# OUTPUT
########

output "hh_batchjob_role_arn" {
  value = aws_iam_role.hh_batchjob_role.arn 
}


output "hh_processing_queue_arn" {
  value = aws_batch_job_queue.hh_processing_queue.arn
}



