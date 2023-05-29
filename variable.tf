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
# ssh port
variable "SSH" {
  default = 22
}

# allow all traffic from every IP addres
variable "allow_all_IP" {
  default = ["0.0.0.0/0"]
}

# Jenkins port
variable "Jenkin" {
  default = 8080
}

variable "egress_from_and_to" {
  default = 0
}

variable "egress_protocol" {
  default = "-1"
}

# sonarQube port
variable "SonarQube" {
  default = 9000
}
# Docker AMI which ubuntun and london eu-west 2 region
variable "AMI-ubuntu" {
  default = "ami-09744628bed84e434"
}

# AMI which redhat and london eu-west 2 region
variable "ami-redhat" {
  default = "ami-08d9bb4bfe39be5c2"
}

#instance type
variable "instance_type" {
  default = "t2.medium"
}

# ALB ingress application traffic for docker
variable "app_port" {
  default = 8080
}

# ALB ingress listener traffic for docker
variable "listener_port" {
  default = "80"
}

# ALB ingress listener traffic for docker for ingree stage SG
variable "unsecured_listener_port" {
  default = 80
}

# ALB ingress listener traffic for docker for ingree Prod SG
variable "secured_listener_port" {
  default = 443
}

# DOMAIN NAME
variable "domain_name" {
  default = "greatestshalomventures.com"
}

