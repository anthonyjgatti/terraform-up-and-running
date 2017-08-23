provider "aws" {
  region = "us-east-2"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests."
  default = 8080
}

data "aws_availability_zones" "all" {}

resource "aws_launch_configuration" "example" {
  ami = "ami-44bf9f21"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
                 #!/bin/bash
                 echo "Hello, World" > index.html
                 nohup busybox httpd -f -p "${var.server_port}" &
                 EOF

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform-asg-example"
    propogate_at_launch = true
  }
}

output "public_ip" {
  value = "${aws_instance.example.public_ip}"
}

