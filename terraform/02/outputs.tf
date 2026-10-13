output "selected_vpc_id" {
  description = "ID of the existing VPC"
  value       = data.aws_vpc.selected.id
}

output "selected_vpc_arn" {
  description = "ARN of the existing VPC"
  value       = data.aws_vpc.selected.arn
}
