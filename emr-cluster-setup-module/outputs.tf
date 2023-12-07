output "bucket_name" {
  description = "Raw data S3 bucket"
  value       = aws_s3_bucket.source-bucket.id
}


output "bucket_arn" {
  description = "arn of the bucket"
  value       = aws_s3_bucket.source-bucket.arn
}

output "spark_app_bucket_name" {
  description = "spark app bucket"
  value       = aws_s3_bucket.spark-app-bucket.id
}

