
resource "aws_key_pair" "my-ssh-key" {
  key_name = "my-ssh-key"
  #public_key = "ssh-rsa my-public-key"
  public_key = "${file(var.PATH_TO_PUBLIC_KEY)}"
  
}

resource "aws_instance" "example" {
  ami = "${lookup(var.AMIS, var.AWS_REGIONS)}"  ## uses lookup to find the right instance
  instance_type = "t2.micro"


  ### DONOT EXECUTE THIS ON TERRAFORM ###
  ### ------------------------------- ###
  ### provisioning software can be done in multiple ways
  ### 1. build your own custom AMI (using Packr)
  ### 2. boot standardized AMIs and then install s/w file uploads, remote-exec, automations like chef, puppet, ansible

  ### using file uploads
  provisioner "file" {
     source = "app.conf"
     destination = "/etc/myapp.conf"
  }

  ### using file uploads with overriding connections
  provisioner "file" {
     source = "app.conf"
     destination = "/etc/myapp.conf"
     connection {
       user = "${var.instance_username}"
       password = "${var.instance_password}"
     }
  }

  ### using SSH keypairs (for EC2 Instances)
  key_name = "${aws_key_pair.my-ssh-key.key_name}"

  provisioner "file" {
     source = "app.conf"
     destination = "/etc/myapp.conf"
     connection {
       user = "${var.instance_username}"
       private_key = "${file(var.PATH_TO_PRIVATE_KEY)}"
     }
  }

  ### using remote-exec
  ### executing a command using provisioner
  provisioner "remote-exec" {
    inline = [
      "chmod +x /etc/myapp.conf",
      "sudo /etc/myapp.conf"
    ]
  
  }


  ################### OUTPUT ATTRIBUTES ########################
  provisioner "local-exec" {
      command = "echo ${aws_instance.example.private_ip} >> private_ip_file.txt"
  }

}


### Output the attributes of the aws resources
output "public_ip"{
  value = "${aws_instance.example.public_ip}"
}
output "private_ip"{
  value = "${aws_instance.example.private_ip}"
}