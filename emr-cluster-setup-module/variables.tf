variable "bucket_name" {
  type = string
  description = "project bucket name"
}

variable "raw_prefix" {
  type = string
  description = "prefix where raw objects are stored"
}

variable "tgt_prefix" {
  type = string
  description = "prefix where processed objects are stored"
}

variable "emr_key_name" {
  type = string
  description = "key name for ssh-ing to primary node"
}

variable "emr_subnet_id" {
  type = string
}

variable "spark_app_bucket_name" {
  type = string
  description = "bucket to store spark app files"
}

variable "eip_allocation_id" {
  type = string
  description = "elastic ip allocation id"
}

variable "region_name" {
  type = string
}

variable "account_id" {
  type = string
}