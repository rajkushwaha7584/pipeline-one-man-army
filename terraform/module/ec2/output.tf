output "instance_id" { value = aws_instance.this.id }
output "public_ip" { value = aws_instance.this.public_ip }
output "mysql_volume_id" { value = aws_ebs_volume.mysql.id }
