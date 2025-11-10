output "web_instance_ip" {
  value = aws_instance.webserver.public_ip
}

output "db_instance_ip" {
  value = aws_instance.mongo.public_ip
}
