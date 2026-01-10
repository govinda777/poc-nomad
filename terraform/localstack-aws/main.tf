terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2         = "http://localhost:4566"
    rds         = "http://localhost:4566"
    elasticache = "http://localhost:4566"
    sts         = "http://localhost:4566"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "172.20.0.0/16"
  tags = {
    Name = "aws-vpc"
  }
}

resource "aws_security_group" "nomad" {
  name        = "nomad-sg"
  description = "Allow Nomad traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 4646
    to_port     = 4646
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
