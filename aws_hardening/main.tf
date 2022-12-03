data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = var.cloudtrail_bucket_name
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_public_block" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "coudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.cloudtrail_bucket.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.cloudtrail_bucket.arn}/${var.s3_key_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_cloudtrail" "management" {
  depends_on = [
    aws_s3_bucket.cloudtrail_bucket
  ]
  name                       = var.cloudtrail_name
  s3_bucket_name             = var.cloudtrail_bucket_name
  s3_key_prefix              = var.s3_key_prefix
  is_organization_trail      = var.is_organization_trail
  is_multi_region_trail      = var.is_multi_region_trail
  enable_log_file_validation = true
}

resource "aws_sns_topic" "securityAlerts" {
  name = var.sns_topic_name
}

#To add sns subscription

resource "aws_cloudwatch_event_rule" "vpcChangeAlert" {
  name        = var.vpc_change_rule_name
  description = "Alert if any critical changes are made to the VPC."

  event_pattern = <<EOF
{
  "source": ["aws.ec2"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["ec2.amazonaws.com"],
    "eventName": ["CreateNetworkAcl", "CreateNetworkAclEntry", "DeleteNetworkAcl", "DeleteNetworkAclEntry", "ReplaceNetworkAclEntry", "ReplaceNetworkAclAssociation", "CreateRoute", "CreateRouteTable", "ReplaceRoute", "ReplaceRouteTableAssociation", "DeleteRouteTable", "DeleteRoute", "DisassociateRouteTable", "CreateVpc", "DeleteVpc", "ModifyVpcAttribute", "AcceptVpcPeeringConnection", "CreateVpcPeeringConnection", "DeleteVpcPeeringConnection", "RejectVpcPeeringConnection", "AttachClassicLinkVpc", "DetachClassicLinkVpc", "DisableVpcClassicLink", "EnableVpcClassicLink"]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "sgChangeAlert" {
  name        = var.sg_change_rule_name
  description = "Alert if any critical changes are made to the Security Group."

  event_pattern = <<EOF
{
  "source": ["aws.ec2"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["ec2.amazonaws.com"],
    "eventName": ["AuthorizeSecurityGroupIngress", "AuthorizeSecurityGroupEgress", "RevokeSecurityGroupIngress", "RevokeSecurityGroupEgress"]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "s3ChangeAlert" {
  name        = var.s3_change_rule_name
  description = "Alert if any critical changes are made to S3"

  event_pattern = <<EOF
{
  "source": ["aws.s3"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["s3.amazonaws.com"],
    "eventName": ["PutBucketAcl", "PutBucketPolicy", "PutBucketCors", "DeleteBucketPolicy", "DeleteBucketCors"]
  }
}
EOF
}
