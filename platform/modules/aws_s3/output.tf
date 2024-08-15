# ------
# OUTPUT
# ------

output "bucket_name" {
  value = aws_s3_bucket.source_bucket.id
}
