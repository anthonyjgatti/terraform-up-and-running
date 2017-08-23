provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example" {
  ami = "ami-44bf9f21"
  instance_type = "t2.micro"

  tags {
    Name = "terraform-example"
  }
}


