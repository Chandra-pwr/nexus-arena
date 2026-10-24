terraform {
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
}
variable "domain" { default = "nexus-arena.example.com" }
provider "aws" { region = "ap-south-1" }
resource "aws_route53_zone" "main" { name = var.domain }
output "name_servers" { value = aws_route53_zone.main.name_servers }
