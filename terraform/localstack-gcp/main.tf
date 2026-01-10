terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# We use the AWS provider to interact with the second LocalStack instance
# acting as "GCP" (generic cloud provider)
provider "aws" {
  region                      = "us-west-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2         = "http://localhost:4570" # Maps to 4566 in the second container
    rds         = "http://localhost:4570"
    elasticache = "http://localhost:4570"
    sts         = "http://localhost:4570"
  }
}

resource "aws_vpc" "gcp_main" {
  cidr_block = "172.21.0.0/16"
  tags = {
    Name = "gcp-vpc-simulated"
  }
}
