terraform {
  backend "remote" {
    organization = "better-bat"

    workspaces {
      name = "terraform-demo"
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

variable "main_region" {
  type    = string
  default = "us-east-1"
}

provider "aws" {
  profile = "terraform"
  region  = var.main_region
}

module "vpc" {
  source = "./modules/vpc"
  region = var.main_region
}

resource "aws_instance" "app_server" {
  ami           = module.vpc.ami_id
  subnet_id     = module.vpc.subnet_id
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}

variable "instance_name" {
  description = "Value of the name tag"
  type        = string
  default     = "ExampleAppServerInstance"
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}
