# VPC CIDR BLOCK
variable "aws_vpc" {
  default = "10.0.0.0/16"
}

# Public Subnet1
variable "aws_pub1" {
  default = "10.0.1.0/24"
}

# Public Subnet2
variable "aws_pub2" {
  default = "10.0.2.0/24"
}

# Private Subnet1
variable "aws_priv1" {
  default = "10.0.3.0/24"
}

# Private Subnet2
variable "aws_priv2" {
  default = "10.0.4.0/24"
}

# All IP CIDR
variable "all_ip" {
  default = "0.0.0.0/0"
}