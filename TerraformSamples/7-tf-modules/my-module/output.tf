output "aws-cluster" {
  value = "${aws_instance.instance1.public_ip}, ${aws_instance.instance2.public_ip}, ${aws_instance.instance3.public_ip}"
}