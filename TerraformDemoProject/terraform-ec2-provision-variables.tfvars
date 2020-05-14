####################################################################
## General Configurations
####################################################################

profile = "default"                            
region = "us-east-1"                           # Region for AWS
aws_credentials = "~/.aws/credentials" 

####################################################################
## AWS EC2 Instance Specific Configuration
####################################################################

aws_instance_count = 2                         # provision 2 instances of ec2
aws_ami_instance = "ami-0323c3dd2da7fb37d"     # generic ami for free tier
aws_instance_type = "t2.micro"                 # generic instance type for free tier
aws_iam_instance_profile = "iam_ec2_s3_role"   # role that grants ec2 to connect to s3
aws_ec2_keyname= "MyVMInstanceKeyPair"         # the SSH private key name to connect to aws
aws_ec2_sgrp= ["TerraformDemoSecurityGroup"]   # the security group it tags to.
aws_ec2_tag_name = "TerraformDemoProject"      # the Tag metadata (Name) of the aws ec2 instance
aws_ec2_userdata_file_location = "ec2_user_data/install_python3.sh"  # location of the user data