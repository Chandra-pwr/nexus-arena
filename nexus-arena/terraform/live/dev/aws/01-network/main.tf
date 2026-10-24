module "vpc" {
  source = "../../../../modules/aws/vpc"
  name   = "nexus-dev"
}
output "vpc_id" { value = module.vpc.vpc_id }
output "private_subnets" { value = module.vpc.private_subnets }
