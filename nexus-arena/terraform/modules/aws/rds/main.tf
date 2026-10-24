variable "name" {}
variable "vpc_id" {}
variable "subnet_ids" { type = list(string) }
variable "allowed_sg_id" {}
module "db" {
  source                      = "terraform-aws-modules/rds/aws"
  version                     = "~> 6.0"
  identifier                  = var.name
  engine                      = "postgres"
  engine_version              = "16"
  family                      = "postgres16"
  major_engine_version        = "16"
  instance_class              = "db.t3.micro"
  allocated_storage           = 20
  db_name                     = "auth"
  username                    = "nexus"
  manage_master_user_password = true
  create_db_subnet_group      = true
  subnet_ids                  = var.subnet_ids
  vpc_security_group_ids      = [aws_security_group.db.id]
  skip_final_snapshot         = true
}
resource "aws_security_group" "db" {
  name_prefix = "${var.name}-db"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.allowed_sg_id]
  }
}
output "endpoint" { value = module.db.db_instance_endpoint }
