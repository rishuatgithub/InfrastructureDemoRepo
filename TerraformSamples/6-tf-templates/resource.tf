

data "template_file" "my-template"{
    template = "${file("template.tpl")}"

    vars = {
      "myip" = "${aws_instance.database1.private_ip}"
    }
}

resource "aws_instance" "my-instance" {
  ### some stuff in here

  user_data = "${data.template_file.my-template.rendered}"
}

