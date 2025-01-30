# Configuración de SNS
resource "aws_sns_topic" "this" {
  name = "${var.country}-${var.product}-${var.environment}-${var.topic_name}"
}

# Outputs
output "topic_arn" {
  value = aws_sns_topic.this.arn
}