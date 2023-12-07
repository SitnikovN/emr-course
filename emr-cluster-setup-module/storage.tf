
resource "aws_s3_bucket" "source-bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_object" "raw_prefix" {
  bucket = aws_s3_bucket.source-bucket.bucket
  key    = "${var.raw_prefix}/"
}

resource "aws_s3_object" "tgt_prefix" {
  bucket = aws_s3_bucket.source-bucket.bucket
  key    = "${var.tgt_prefix}/"
}

resource "aws_s3_bucket" "spark-app-bucket" {
  bucket = var.spark_app_bucket_name
}


locals {
  src_files_dir = "data/src_files"
  src_s3_prefix = "${var.raw_prefix}/"
  spark_app_dir = "data/spark_app"
}

resource "aws_s3_object" "provision_source_files" {
  for_each = fileset(local.src_files_dir, "**/*")

  bucket = aws_s3_bucket.source-bucket.id
  source = "${local.src_files_dir}/${each.value}"
  key  = "${local.src_s3_prefix}${each.value}"
  content_type = each.value
}

resource "aws_s3_object" "provision_spark_app_files" {
  for_each = fileset(local.spark_app_dir, "**/*")

  bucket = aws_s3_bucket.spark-app-bucket.id
  source = "${local.spark_app_dir}/${each.value}"
  key  = each.value
  content_type = each.value
}