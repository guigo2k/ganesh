terraform {
  required_version = "~> 0.11.0"

  backend "s3" {
    bucket = "talabat-bd-eu-west-1-terraform"
    key    = "drone-demo/ganesh.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_security_group" "ganesh_demo" {
  name        = "ganesh_demo"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = "vpc-0992bae76c415f251"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
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
    Name = "ganesh_demo"
  }
}

resource "aws_instance" "web" {
  instance_type          = "t2.micro"
  ami                    = "ami-053d1b6039e1098d4"
  subnet_id              = "subnet-017552b4697cc7220"
  key_name               = "infra-dev-eu-west-1-drone"
  vpc_security_group_ids = ["${aws_security_group.ganesh_demo.id}"]

  tags = {
    Name = "ganesh_demo"
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "core"
    }

    inline = [
      "sudo mkdir -p /opt/bin",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m) -o /opt/bin/docker-compose",
      "sudo chmod +x /opt/bin/docker-compose",
      "git clone https://github.com/guigo2k/ganesh",
      "cd ganesh && git checkout v4",
      "docker-compose up",
    ]
  }
}
