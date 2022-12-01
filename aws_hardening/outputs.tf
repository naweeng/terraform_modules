output "cloudtrail_id" {
  value       = join("", aws_cloudtrail.management.*.id)
  description = "The name of the trail"
}

output "cloudtrail_home_region" {
  value       = join("", aws_cloudtrail.management.*.home_region)
  description = "The region in which the trail was created"
}

output "cloudtrail_arn" {
  value       = join("", aws_cloudtrail.management.*.arn)
  description = "The Amazon Resource Name of the trail"
}
