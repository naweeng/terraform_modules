variable "cloudtrail_bucket_name" {
  type        = string
  description = "Cloudtrail Bucket Name"
}

variable "cloudtrail_name" {
  type        = string
  description = "Cloudtrail Name"
}

variable "s3_key_prefix" {
  type        = string
  description = "Prefix for S3 bucket used by Cloudtrail to store logs"
  default     = null
}

variable "is_organization_trail" {
  type        = bool
  default     = false
  description = "The trail is an AWS Organizations trail"
}

variable "is_multi_region_trail" {
  type        = bool
  default     = true
  description = "Specifies whether the trail is created in the current region or in all regions"
}

variable "sns_topic_name" {
  type        = string
  description = "SNS topic name"
}

variable "vpc_change_rule_name" {
  type        = string
  description = "EventBridge Rule Name for VPC change detection."
}

variable "sg_change_rule_name" {
  type        = string
  description = "EventBridge Rule Name for SG change detection."
}

variable "s3_change_rule_name" {
  type        = string
  description = "EventBridge Rule Name for S3 change detection."
}
