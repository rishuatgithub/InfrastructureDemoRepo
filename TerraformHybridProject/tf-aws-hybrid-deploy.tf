#####################################################################
### Terraform template for provisioning AWS instances in a VPC
### Author: Rishu Shrivastava
### Last Updated: 06-Jun-2020
#####################################################################

provider "aws" {
    profile="default"
    region="us-east-1"
}

## Define the VPC
resource "aws_vpc" "master_vpc" {
    cidr_block = "20.0.0.0/16"
    tags = {
        Name = "master-vpc-us-east-01"
    }
}

## Define the Internet Gateway
resource "aws_internet_gateway" "vpc_IG" {
    vpc_id = aws_vpc.master_vpc.id
    tags = {
        Name = "master-vpc-IG"
    }
}


## Define Subnets (1 Public and 1 Private inside AZ: us-east-1a)

#  Public Subnet
resource "aws_subnet" "vpc_subnet_useast1a_public_01" {
    vpc_id = aws_vpc.master_vpc.id
    cidr_block = "20.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "vpc-subnet-useast1a-public-01"
    }
}

# Private Subnet
resource "aws_subnet" "vpc_subnet_useast1a_private_01" {
    vpc_id = aws_vpc.master_vpc.id
    cidr_block = "20.0.2.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "vpc-subnet-useast1a-private-01"
    }
}

## Routing Tables

# RT and RA for public subnet
resource "aws_route_table" "vpc_public_RT" {
    vpc_id = aws_vpc.master_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.vpc_IG.id 
    }

    tags = {
        Name = "vpc-public-RT"
    }
}

resource "aws_route_table_association" "vpc_route_association_public_subnet_01" {
    subnet_id = aws_subnet.vpc_subnet_useast1a_public_01.id 
    route_table_id = aws_route_table.vpc_public_RT.id
}

# RT and RA for private subnet
resource "aws_route_table" "vpc_private_RT" {
    vpc_id = aws_vpc.master_vpc.id
    tags = {
        Name = "vpc-private-RT"
    }
}

resource "aws_route_table_association" "vpc_route_association_private_subnet_01" {
    subnet_id = aws_subnet.vpc_subnet_useast1a_private_01.id 
    route_table_id = aws_route_table.vpc_private_RT.id 
}



## Security Group

# SG for Public api
resource "aws_security_group" "vpc_public_SG_1"{
    name = "vpc-public-SG-01"
    description = "Allows SSH, HTTP, HTTPS. Used in public subnets for internet access"
    vpc_id = aws_vpc.master_vpc.id

    ingress {
        description = "Allow SSH from internet"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Allow HTTP from internet"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Allow HTTPS from internet"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "vpc-public-SG-01"
    }

}

# SG for Bastion Host
resource "aws_security_group" "vpc_bastion_SG"{
    name = "vpc-bastion-sg"
    description = "Allows SSH and ICMP to the private subnet using bastion host"
    vpc_id = aws_vpc.master_vpc.id

    ingress {
        description = "Allow SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp" 
        cidr_blocks = ["86.14.8.180/32"]  ## my IP cidr block for hardening
    }

    ingress {
        description = "Allow ICMP"
        from_port   = "-1"
        to_port     = "-1"
        protocol    = "icmp" 
        cidr_blocks = ["86.14.8.180/32"]  ## my IP cidr block for hardening
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "vpc-bastion-SG"
    }

}

# SG for private api
resource "aws_security_group" "vpc_private_SG_1"{
    name = "vpc-private-SG-01"
    description = "Allows only ICMP and MySQL database connection. It allows SSH via bastion host only. Used in private subnet"
    vpc_id = aws_vpc.master_vpc.id

    ingress {
        description = "Allow TCP - MySQL/Aurora"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = [aws_subnet.vpc_subnet_useast1a_public_01.cidr_block]
    }

    ingress {
        description = "Allow ICMP"
        from_port   = "-1"
        to_port     = "-1"
        protocol    = "icmp"
        cidr_blocks = [aws_subnet.vpc_subnet_useast1a_public_01.cidr_block]
    }

    ingress {
        description = "Allow SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        security_groups = [aws_security_group.vpc_bastion_SG.id] ## open ssh from bastion sg
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "vpc-private-SG-01"
    }

}



## Launch EC2 Instance on Public Subnet
resource "aws_instance" "vpc_ec2_instance_public_01" {
    #count=1
    ami="ami-0323c3dd2da7fb37d"
    instance_type = "t2.micro"
    key_name = "MyVMInstanceKeyPair"
    associate_public_ip_address = true

    subnet_id = aws_subnet.vpc_subnet_useast1a_public_01.id
    security_groups = [aws_security_group.vpc_public_SG_1.id]

    tags = {
        Name = "vpc-ec2-instance-public-01"
    }

    user_data = file("aws-user-data-webDMZ.sh")
}


## Launch EC2 Instance on Private Subnet
resource "aws_instance" "vpc_ec2_instance_private_01" {
    #count=1
    ami="ami-0323c3dd2da7fb37d"
    instance_type = "t2.micro"
    key_name = "MyVMInstanceKeyPair"

    subnet_id = aws_subnet.vpc_subnet_useast1a_private_01.id
    security_groups = [aws_security_group.vpc_private_SG_1.id]

    tags = {
        Name = "vpc-ec2-instance-private-01"
    }

    user_data = file("aws-user-data-private.sh")
}

## Launch Bastion Host - EC2 Instance on Public Subnet
resource "aws_instance" "vpc_ec2_instance_bastion" {
    #count=1
    ami="ami-0323c3dd2da7fb37d"
    instance_type = "t2.micro"
    key_name = "MyVMInstanceKeyPair"
    associate_public_ip_address = true

    subnet_id = aws_subnet.vpc_subnet_useast1a_public_01.id
    security_groups = [aws_security_group.vpc_bastion_SG.id]

    tags = {
        Name = "vpc-ec2-instance-bastion"
    }

}


## Output the IP address

output "AWS-EC2-Public-Instance-01-IP" {
    description = "Shows the public IP of the EC2 instance in public subnet"
    value = aws_instance.vpc_ec2_instance_public_01.public_ip
}

output "AWS-EC2-Private-Instance-01-IP" {
    description = "Shows the private IP address for the EC2 instance in private subnet"
    value = aws_instance.vpc_ec2_instance_private_01.private_ip
}

output "AWS-EC2-Bastion-IP" {
    description = "Shows the public IP address for the Bastion Host"
    value = aws_instance.vpc_ec2_instance_bastion.public_ip
}