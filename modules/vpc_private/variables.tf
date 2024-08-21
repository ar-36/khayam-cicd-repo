#terraform/modules/vpc_private/variables.tf
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "VPC list of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.0.0/18", "10.0.64.0/18"]
}

variable "tags" {
  description = "Tags to apply to VPC resources"
  type        = map(any)
  default     = {}
}

variable "create_bastion" {
  description = "Create a bastion host or not"
  type        = bool
  default     = false
}

variable "bastion_instance_type" {
  description = "ec2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "bastion_ssh_key_name" {
  description = "SSH Key name"
  type        = string
  default     = ""
}
