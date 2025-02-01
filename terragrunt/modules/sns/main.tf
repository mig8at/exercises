# Configuración de SNS
resource "aws_sns_topic" "this" {
  name = "${var.country}-${var.product}-${var.environment}-${var.topic_name}"
  tags = var.tags
}

# Outputs
output "topic_arn" {
  value = aws_sns_topic.this.arn
}