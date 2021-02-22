data "aws_ip_ranges" "european_ec2"{
    regions = [ "eu-west-1", "eu-central-1" ]
    services = [ "ec2" ]
}

resource "aws_security_group" "from_europe" {
  name = "from_europe"

  ingress = {
    cidr_blocks = [ "${data.aws_ip_ranges.european_ec2.cidr_blocks}" ]
    from_port = 443
    protocol = "tcp"
    self = false
    to_port = 443

    tags = {
      "createDate" = "${data.aws_ip_ranges.european_ec2.create_date}"
      "syncToken" = "${data.aws_ip_ranges.european_ec2.sync_token}"
    }
  }
}