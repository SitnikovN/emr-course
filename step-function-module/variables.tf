variable "step_function_name" {
  type = string
  description = "name of step function"
}

variable "bucket_arn" {
  type = string
  description = "source files bucket arn"
}

variable "bucket_name" {
  type = string
  description = "source files bucket arn"
}

variable "spark_app_bucket_name" {
  type = string
  description = "spark app bucket"
}

variable "raw_prefix" {
  description = "Prefix to store source data"
  type = string
}

variable "tgt_prefix" {
  description = "Prefix to store processed data"
  type = string
}

variable "region_name" {
  type = string
}

variable "account_id" {
  type = string
}