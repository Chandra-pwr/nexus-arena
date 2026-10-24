data "terraform_remote_state" "net" {
  backend = "s3"
  config = {
    bucket = "nexus-arena-tfstate-CHANGEME"
    key    = "staging/aws/01-network.tfstate"
    region = "ap-south-1"
  }
}
module "eks" {
  source     = "../../../../modules/aws/eks"
  name       = "nexus-staging"
  vpc_id     = data.terraform_remote_state.net.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.net.outputs.private_subnets
}
module "rds" {
  source        = "../../../../modules/aws/rds"
  name          = "nexus-staging"
  vpc_id        = data.terraform_remote_state.net.outputs.vpc_id
  subnet_ids    = data.terraform_remote_state.net.outputs.private_subnets
  allowed_sg_id = module.eks.node_sg_id
}
output "cluster_name" { value = module.eks.cluster_name }
output "db_endpoint" { value = module.rds.endpoint }
