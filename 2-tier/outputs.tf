output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.web_alb.dns_name
}

output "db_endpoint" {
  description = "The connection endpoint for the RDS"
  value       = aws_db_instance.database.endpoint
}