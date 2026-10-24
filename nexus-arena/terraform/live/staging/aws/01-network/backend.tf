terraform {
  required_version = ">= 1.6"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
  backend "s3" {
    bucket         = "nexus-arena-tfstate-CHANGEME"
    key            = "staging/aws/01-network.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "nexus-arena-tflock"
  }
}
provider "aws" { region = "ap-south-1" }
