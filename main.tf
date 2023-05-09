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