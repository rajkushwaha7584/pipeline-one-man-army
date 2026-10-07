module "vpc" {
  source             = "./module/vpc"
  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
}

module "ecr" {
  source       = "./module/ecr"
  project_name = var.project_name
  environment  = var.environment
}

resource "random_password" "mysql_root" {
  length  = 32
  special = false
}

resource "random_password" "mysql_app" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "database" {
  name                    = "${var.project_name}/${var.environment}/mysql"
  recovery_window_in_days = 0
}

module "iam" {
  source              = "./module/iam"
  project_name        = var.project_name
  environment         = var.environment
  database_secret_arn = aws_secretsmanager_secret.database.arn
  ecr_repository_arns = module.ecr.repository_arns
}

module "ec2" {
  source                = "./module/ec2"
  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.private_subnet_ids[0]
  alb_security_group_id = module.vpc.alb_security_group_id
  instance_type         = var.instance_type
  key_name              = var.key_name
  iam_instance_profile  = module.iam.instance_profile_name
  database_secret_name  = aws_secretsmanager_secret.database.name
  mysql_volume_size     = var.mysql_volume_size
  aws_region            = var.aws_region
  depends_on            = [aws_secretsmanager_secret_version.database]
}

module "alb_asg" {
  source                 = "./module/alb_asg"
  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  public_subnet_ids      = module.vpc.public_subnet_ids
  alb_security_group_id  = module.vpc.alb_security_group_id
  target_instance_id     = module.ec2.instance_id
}

module "rds" {
  source             = "./module/rds"
  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = var.vpc_cidr
  private_subnet_ids = module.vpc.private_subnet_ids
  db_name            = "skillpulse"
  db_username        = "dbadmin"
  db_password        = random_password.mysql_root.result
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id = aws_secretsmanager_secret.database.id
  secret_string = jsonencode({
    db_host       = module.rds.db_address
    app_password  = random_password.mysql_app.result
    root_password = random_password.mysql_root.result
  })
}
