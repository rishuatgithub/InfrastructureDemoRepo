
provider "aws" {
    profile="default"
    region="us-east-1"
}

## define a vpc
resource "aws_vpc" "rks_aws_hybrid_vpc" {
    cidr_block = "20.0.0.0/16"
    tags = {
        Name = "rks_hybrid_vpc"
    }
}

## Internet gateway
resource "aws_internet_gateway" "rks_hybrid_ig" {
    vpc_id = aws_vpc.rks_aws_hybrid_vpc.id
    tags = {
        Name = "rks_hybrid_ig"
    }
}


### Subnets
## Public Subnet
resource "aws_subnet" "rks_hybrid_vpc_subnet_public" {
    vpc_id = aws_vpc.rks_aws_hybrid_vpc.id
    cidr_block = "20.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "rks_hybrid_subnet-public-01"
    }
}

## Private Subnet
resource "aws_subnet" "rks_hybrid_vpc_subnet_private" {
    vpc_id = aws_vpc.rks_aws_hybrid_vpc.id
    cidr_block = "20.0.2.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "rks_hybrid_subnet-private-01"
    }
}

## Routing Tables
# RT for public
resource "aws_route_table" "rks_hybrid_vpc_RT_public" {
    vpc_id = aws_vpc.rks_aws_hybrid_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.rks_hybrid_ig.id 
    }

    tags = {
        Name = "rks_hybrid_vpc_RT_public"
    }
}

resource "aws_route_table_association" "rks_hybrid_vpc_route_association_public" {
    subnet_id = aws_subnet.rks_hybrid_vpc_subnet_public.id 
    route_table_id = aws_route_table.rks_hybrid_vpc_RT_public.id 
}

# RT for private
resource "aws_route_table" "rks_hybrid_vpc_RT_private" {
    vpc_id = aws_vpc.rks_aws_hybrid_vpc.id
    tags = {
        Name = "rks_hybrid_vpc_RT_private"
    }
}

resource "aws_route_table_association" "rks_hybrid_vpc_route_association_private" {
    subnet_id = aws_subnet.rks_hybrid_vpc_subnet_private.id 
    route_table_id = aws_route_table.rks_hybrid_vpc_RT_private.id 
}



#### Security Group

## SG for public instances
resource "aws_security_group" "rks_hybrid_webdmz_sg"{
    name = "rks_hybrid_webdmz_sg"
    description = "Allows SSH, HTTP, HTTPS. Used for Public Subnet groups"
    vpc_id = aws_vpc.rks_aws_hybrid_vpc.id

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
        Name = "rks_hybrid_webdmz_sg"
    }

}

## SG for private instances
resource "aws_security_group" "rks_hybrid_db_private_sg"{
    name = "rks_hybrid_db_private_sg"
    description = "Allows only database connections"
    vpc_id = aws_vpc.rks_aws_hybrid_vpc.id

    ingress {
        description = "Allow TCP - MySQL/Aurora"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = [aws_vpc.rks_aws_hybrid_vpc.cidr_block]
    }

    ingress {
        description = "Allow ICMP"
        from_port   = "-1"
        to_port     = "-1"
        protocol    = "icmp"
        cidr_blocks = [aws_vpc.rks_aws_hybrid_vpc.cidr_block]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "rks_hybrid_db_private_sg"
    }

}


#### Launch EC2 Instance on Public Subnet
resource "aws_instance" "rks_hybrid_ec2_public_vm01" {
    count=1
    ami="ami-0323c3dd2da7fb37d"
    instance_type = "t2.micro"
    key_name = "MyVMInstanceKeyPair"
    associate_public_ip_address = true

    subnet_id = aws_subnet.rks_hybrid_vpc_subnet_public.id
    security_groups = [aws_security_group.rks_hybrid_webdmz_sg.id]

    tags = {
        Name = "rks_hybrid_ec2_public_vm01"
    }

    user_data = file("aws-user-data.sh")
}

#### Launch EC2 Instance on Private Subnet
resource "aws_instance" "rks_hybrid_ec2_private_vm01" {
    count=1
    ami="ami-0323c3dd2da7fb37d"
    instance_type = "t2.micro"

    subnet_id = aws_subnet.rks_hybrid_vpc_subnet_private.id
    security_groups = [aws_security_group.rks_hybrid_db_private_sg.id]

    tags = {
        Name = "rks_hybrid_ec2_private_vm01"
    }

    user_data = file("aws-user-data.sh")
}

