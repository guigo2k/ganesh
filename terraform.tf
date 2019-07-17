terraform {
  required_version = "~> 0.11.0"
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_security_group" "allow_ganesh" {
  name        = "allow_ganesh"
  description = "Allow HTTP inbound traffic"

  ingress {
    # TLS (change to whatever ports you need)
    from_port = 9000
    to_port   = 9000
    protocol  = "tcp"

    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ganesh"
  }
}

resource "aws_instance" "web" {
  instance_type          = "t2.micro"
  ami                    = "ami-053d1b6039e1098d4"
  subnet_id              = "subnet-0a8d31a8431e62240"
  vpc_security_group_ids = ["${aws_security_group.allow_ganesh.id}"]

  tags = {
    Name = "Ganesh"
  }


  provisioner "remote-exec" {
    inline = [
      "mkdir -p /opt/bin",
      "curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m) -o /opt/bin/docker-compose",
      "chmod +x /opt/bin/docker-compose"
    ]
  }
}
