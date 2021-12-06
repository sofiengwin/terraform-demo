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

# module "vpc" {
#   source = "./modules/vpc"
#   region = var.main_region
# }

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "terraform"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a"]
  public_subnets = ["10.0.1.0/24"]


}


resource "aws_security_group" "my-sg" {
  vpc_id = module.vpc.vpc_id
  name   = join("_", ["sg", module.vpc.vpc_id])
  dynamic "ingress" {
    for_each = var.rules
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["proto"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-Dynamic-SG"
  }
}

resource "aws_instance" "app_server" {
  ami             = data.aws_ssm_parameter.this.value
  subnet_id       = module.vpc.public_subnets[0]
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.my-sg.id]
  user_data       = fileexists("script.sh") ? file("script.sh") : null

  tags = {
    Name = var.instance_name
  }
}

data "aws_ssm_parameter" "this" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
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
