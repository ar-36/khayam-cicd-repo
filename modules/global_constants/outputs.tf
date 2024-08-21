#terraform/modules/global_constants/outputs.tf

output "region" {
  description = "Default AWS region"
  value       = "us-east-1"
}

output "default_azs" {
  description = "Default availability zones"
  value       = ["us-east-1a", "us-east-1b"]
}

output "network_account_id" {
  description = "Network Account id"
  value       = "6542876543152"
}

output "network_vpc_cidr" {
  description = "Network account CIDR"
  value       = "10.163.0.0/24"
}

output "network_vpc_id" {
  description = "Network VPC id"
  value       = "vpc-0f047ae2e4e2192ere"
}
