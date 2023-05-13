# Create Custom VPC
resource "aws_vpc" "lington-vpc" {
  cidr_block = var.aws_vpc

  tags = {
    Name = "lington-vpc"
  }
}

# Create a Public Subnet01 in AZ1
resource "aws_subnet" "lington-pub1" {
  vpc_id            = aws_vpc.lington-vpc.id
  cidr_block        = var.aws_pub1
  availability_zone = "eu-west-2a"

  tags = {
    Name = "lington-pub1"
  }
}

#  Create a Public Subnet02 in AZ2
resource "aws_subnet" "lington-pub2" {
  vpc_id            = aws_vpc.lington-vpc.id
  cidr_block        = var.aws_pub2
  availability_zone = "eu-west-2b"

  tags = {
    Name = "lington-pub2"
  }
}

#  Create a Private Subnet01 in AZ1
resource "aws_subnet" "lington-priv1" {
  vpc_id            = aws_vpc.lington-vpc.id
  cidr_block        = var.aws_priv1
  availability_zone = "eu-west-2a"

  tags = {
    Name = "lington-priv1"
  }
}

#  Create a Private Subnet02 in AZ2
resource "aws_subnet" "lington-priv2" {
  vpc_id            = aws_vpc.lington-vpc.id
  cidr_block        = var.aws_priv2
  availability_zone = "eu-west-2b"

  tags = {
    Name = "lington-priv2"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "lington-igw" {
  vpc_id = aws_vpc.lington-vpc.id

  tags = {
    Name = "lington-igw"
  }
}

# Create Nat Gateway
resource "aws_nat_gateway" "lington-nat" {
  allocation_id = aws_eip.lington_EIP.id
  subnet_id     = aws_subnet.lington-pub1.id

  tags = {
    Name = "lington-nat"
  }
}

# Creating Elastic IP for NAT Gateway
resource "aws_eip" "lington_EIP" {
  vpc = true
}

# Create Public Route Table, attach to VPC, allow access from every ip, attach to IGW
resource "aws_route_table" "lington_RT_Pub_SN" {
  vpc_id = aws_vpc.lington-vpc.id

  route {
    cidr_block = var.all_ip
    gateway_id = aws_internet_gateway.lington-igw.id
  }

  tags = {
    Name = "lington_RT_Pub_SN"
  }
}

# Create Private Route Table, attach to VPC, allow access from every ip, attach to NGW
resource "aws_route_table" "lington_RT_Pri_SN" {
  vpc_id = aws_vpc.lington-vpc.id

  route {
    cidr_block     = var.all_ip
    nat_gateway_id = aws_nat_gateway.lington-nat.id
  }

  tags = {
    Name = "lington_RT_Pri_SN"
  }
}

# Creating Route Table Associations 
resource "aws_route_table_association" "lington_Public_RT1" {
  subnet_id      = aws_subnet.lington-pub1.id
  route_table_id = aws_route_table.lington_RT_Pub_SN.id
}
resource "aws_route_table_association" "lington_Public_RT2" {
  subnet_id      = aws_subnet.lington-pub2.id
  route_table_id = aws_route_table.lington_RT_Pub_SN.id
}
resource "aws_route_table_association" "lington_Private_RT1" {
  subnet_id      = aws_subnet.lington-priv1.id
  route_table_id = aws_route_table.lington_RT_Pri_SN.id
}
resource "aws_route_table_association" "lington_Private_RT2" {
  subnet_id      = aws_subnet.lington-priv2.id
  route_table_id = aws_route_table.lington_RT_Pri_SN.id
}
# Create keypair with Terraform
resource "tls_private_key" "lington_Key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "lington_Key_priv" {
  filename        = "lington_key.pem"
  content         = tls_private_key.lington_Key.private_key_pem
  file_permission = "600"
}

resource "aws_key_pair" "lington_Key_pub" {
  key_name   = "lington_key"
  public_key = tls_private_key.lington_Key.public_key_openssh
}

# Creating Security group ansible(FrontEnd)
resource "aws_security_group" "ansible_lington_FrontEndSG" {
  name        = "lington Ansible"
  description = "Ansible traffic"
  vpc_id      = aws_vpc.lington-vpc.id

  ingress {
    description = "SSH rule VPC"
    from_port   = var.SSH
    to_port     = var.SSH
    protocol    = "tcp"
    cidr_blocks = var.allow_all_IP
  }


  egress {
    from_port   = var.egress_from_and_to
    to_port     = var.egress_from_and_to
    protocol    = var.egress_protocol
    cidr_blocks = var.allow_all_IP
  }

  tags = {
    Name = "lington_Ansible"
  }
}

# Creating Security group Jenkin(FrontEnd)
resource "aws_security_group" "Jenkin_lington_FrontEndSG" {
  name        = "lington Jenkin"
  description = "Jenkins traffic"
  vpc_id      = aws_vpc.lington-vpc.id

  ingress {
    description = "SSH rule VPC"
    from_port   = var.SSH
    to_port     = var.SSH
    protocol    = "tcp"
    cidr_blocks = var.allow_all_IP
  }

  ingress {
    description = "Jenkins port"
    from_port   = var.Jenkin
    to_port     = var.Jenkin
    protocol    = "tcp"
    cidr_blocks = var.allow_all_IP
  }

  egress {
    from_port   = var.egress_from_and_to
    to_port     = var.egress_from_and_to
    protocol    = var.egress_protocol
    cidr_blocks = var.allow_all_IP
  }

  tags = {
    Name = "lington_Jenkin"
  }
}

# Creating Security group bastion(FrontEnd)
resource "aws_security_group" "bastion_lington_FrontEndSG" {
  name        = "lington bastion"
  description = "bastion traffic"
  vpc_id      = aws_vpc.lington-vpc.id

  ingress {
    description = "SSH rule VPC"
    from_port   = var.SSH
    to_port     = var.SSH
    protocol    = "tcp"
    cidr_blocks = var.allow_all_IP
  }


  egress {
    from_port   = var.egress_from_and_to
    to_port     = var.egress_from_and_to
    protocol    = var.egress_protocol
    cidr_blocks = var.allow_all_IP
  }

  tags = {
    Name = "lington_bastion"
  }
}

# Creating Security group sonarQube(FrontEnd)
resource "aws_security_group" "sonarQube_lington_FrontEndSG" {
  name        = "lington sonarQube"
  description = "sonarqube traffic"
  vpc_id      = aws_vpc.lington-vpc.id

  ingress {
    description = "SSH rule VPC"
    from_port   = var.SSH
    to_port     = var.SSH
    protocol    = "tcp"
    cidr_blocks = var.allow_all_IP
  }

  ingress {
    description = "SonarQube rule VPC"
    from_port   = var.SonarQube
    to_port     = var.SonarQube
    protocol    = "tcp"
    cidr_blocks = var.allow_all_IP
  }


  egress {
    from_port   = var.egress_from_and_to
    to_port     = var.egress_from_and_to
    protocol    = var.egress_protocol
    cidr_blocks = var.allow_all_IP
  }

  tags = {
    Name = "lington_solarQube"
  }
}

# Creating Security group docker stage(BackEnd)
resource "aws_security_group" "docker_stage_lington_BackEndSG" {
  name        = "lington docker prod"
  description = "docker stage traffic"
  vpc_id      = aws_vpc.lington-vpc.id

  ingress {
    description     = "SSH rule VPC"
    from_port       = var.SSH
    to_port         = var.SSH
    protocol        = "tcp"
    security_groups = [aws_security_group.ansible_lington_FrontEndSG.id, aws_security_group.bastion_lington_FrontEndSG.id]
  }



  egress {
    from_port   = var.egress_from_and_to
    to_port     = var.egress_from_and_to
    protocol    = var.egress_protocol
    cidr_blocks = var.allow_all_IP
  }

  tags = {
    Name = "lington_docker_stage"
  }
}

# Creating Security group docker production(BackEnd)
resource "aws_security_group" "docker_prod_lington_BackEndSG" {
  name        = "lington docker production"
  description = "docker production traffic"
  vpc_id      = aws_vpc.lington-vpc.id

  ingress {
    description     = "SSH rule VPC"
    from_port       = var.SSH
    to_port         = var.SSH
    protocol        = "tcp"
    security_groups = [aws_security_group.ansible_lington_FrontEndSG.id, aws_security_group.bastion_lington_FrontEndSG.id]
  }



  egress {
    from_port   = var.egress_from_and_to
    to_port     = var.egress_from_and_to
    protocol    = var.egress_protocol
    cidr_blocks = var.allow_all_IP
  }

  tags = {
    Name = "lington_docker_prod"
  }
}
