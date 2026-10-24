variable "name" {}
variable "cidr" { default = "10.0.0.0/16" }
data "aws_availability_zones" "a" { state = "available" }
module "vpc" {
  source              = "terraform-aws-modules/vpc/aws"
  version             = "~> 5.0"
  name                = var.name
  cidr                = var.cidr
  azs                 = slice(data.aws_availability_zones.a.names, 0, 2)
  private_subnets     = [cidrsubnet(var.cidr, 8, 1), cidrsubnet(var.cidr, 8, 2)]
  public_subnets      = [cidrsubnet(var.cidr, 8, 101), cidrsubnet(var.cidr, 8, 102)]
  enable_nat_gateway  = true
  single_nat_gateway  = true
  public_subnet_tags  = { "kubernetes.io/role/elb" = 1 }
  private_subnet_tags = { "kubernetes.io/role/internal-elb" = 1 }
}
output "vpc_id" { value = module.vpc.vpc_id }
output "private_subnets" { value = module.vpc.private_subnets }
