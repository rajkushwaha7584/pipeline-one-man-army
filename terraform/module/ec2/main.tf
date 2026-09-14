module "ec2_instance" {
  source        = "terraform-aws-modules/ec2-instance/aws"
  name          = "single-instance"
  instance_type = var.instance_type
  key_name      = var.key_name
  monitoring    = true
  subnet_id     = var.subnet_id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}