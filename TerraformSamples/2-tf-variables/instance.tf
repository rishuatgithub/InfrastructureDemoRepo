resource "aws_instance" "example" {
  ami = "${lookup(var.AMIS, var.AWS_REGIONS)}"  ## uses lookup to find the right instance
  instance_type = "t2.micro"
}