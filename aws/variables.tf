variable "aws_region" {
  default = "eu-central-1"
}

variable "project_name" {
  default = "terraform-homelab"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

variable "my_ip" {
  description = "46.128.131.176/32"
  type        = string
  sensitive   = true
}

variable "ami_id" {
  default = "ami-0faab6bdbac9486fb" # Ubuntu 22.04 Frankfurt
}

variable "aws_account_id" {
  description = "Deine AWS Account ID (12-stellig)"
  default     = "386381158423"
}

variable "ssh_public_key" {
  description = "SSH Public Key für EC2"
  type        = string
}

