terraform {
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
}
variable "region" { default = "ap-south-1" }
variable "bucket" { default = "nexus-arena-tfstate-CHANGEME" } # must be globally unique
provider "aws" { region = var.region }
resource "aws_s3_bucket" "state" { bucket = var.bucket }
resource "aws_s3_bucket_versioning" "v" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_dynamodb_table" "lock" {
  name         = "nexus-arena-tflock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
