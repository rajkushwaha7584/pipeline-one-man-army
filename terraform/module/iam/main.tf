data "aws_iam_policy_document" "instance_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "k3s_host" {
  name               = "${var.project_name}-${var.environment}-k3s-host"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.k3s_host.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.k3s_host.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy_document" "runtime" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.database_secret_arn]
  }
}

resource "aws_iam_role_policy" "runtime" {
  name   = "read-database-secret"
  role   = aws_iam_role.k3s_host.id
  policy = data.aws_iam_policy_document.runtime.json
}

resource "aws_iam_instance_profile" "k3s_host" {
  name = "${var.project_name}-${var.environment}-k3s-host"
  role = aws_iam_role.k3s_host.name
}
