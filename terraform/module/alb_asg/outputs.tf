output "dns_name" { value = aws_lb.this.dns_name }
output "application_url" { value = "http://${aws_lb.this.dns_name}" }
