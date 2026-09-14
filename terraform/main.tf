# Call the VPC Module
module "vpc" {
  source             = "./module/vpc"
  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
}

# Call the EC2 Module
module "ec2" {
  source             = "./module/ec2"
  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.public_subnet_ids[0] # Places EC2 in the first public subnet
  instance_type      = var.instance_type
  key_name           = var.key_name
  enable_public_ip   = true
}
resource "aws_key_pair" "user1" {
  key_name   = "user1"
  public_key = file("~/.ssh/user1.pub")
}