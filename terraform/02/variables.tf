variable "aws_region" {
  type        = string
  description = "AWS region containing the existing VPC"
}

variable "vpc_id" {
  type        = string
  description = "Existing VPC ID to look up in your AWS account"
  default     = "vpc-079caa43a3a1b4048"
}
