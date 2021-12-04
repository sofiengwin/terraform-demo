terraform {
  backend "remote" {
    workspaces {
      name = "Example"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = "~> 1.0.0"
}

provider "aws" {
  profile = "terraform"
  region  = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-061ac2e015473fbe2"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}

variable "instance_name" {
  description = "Value of the name tag"
  type = string
  default = "ExampleAppServerInstance"
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}
