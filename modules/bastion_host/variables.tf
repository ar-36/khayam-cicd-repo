variable "create_module" {
  description = "true to create module, false otherwise"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "VPC ID"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ingress_cidr" {
  description = "CIDR of incoming connections"
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  description = "ec2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami" {
  description = "ec2 AMI"
  type        = string
  default     = "ami-04eefa5fdf0d67698"
}

variable "ssh_key_name" {
  description = "SSH Key name"
  type        = string
}
