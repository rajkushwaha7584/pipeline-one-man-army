data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-6.1-x86_64"]
  }
}

resource "aws_security_group" "k3s_host" {
  name_prefix = "${var.project_name}-${var.environment}-k3s-"
  vpc_id      = var.vpc_id
  description = "Public web access only; host administration is through SSM"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.k3s_host.id]
  user_data = templatefile("${path.module}/k3s-bootstrap.sh.tftpl", {
    aws_region           = var.aws_region
    database_secret_name = var.database_secret_name
  })

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  tags = { Name = "${var.project_name}-${var.environment}-k3s-host" }
}

resource "aws_ebs_volume" "mysql" {
  availability_zone = aws_instance.this.availability_zone
  size              = var.mysql_volume_size
  type              = "gp3"
  encrypted         = true
  tags              = { Name = "${var.project_name}-${var.environment}-mysql" }
}

resource "aws_volume_attachment" "mysql" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.mysql.id
  instance_id = aws_instance.this.id
}
