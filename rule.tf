# === Inputs ===
variable "lambda_function_name" {
  description = "Nome da Lambda já existente"
  type        = string
}

# Busca a Lambda existente
data "aws_lambda_function" "target" {
  function_name = var.lambda_function_name
}

# Regra de agendamento (06:00 UTC = 03:00 America/Sao_Paulo)
resource "aws_cloudwatch_event_rule" "daily_3am_brt_as_utc" {
  name                = "daily-3am-brt-as-utc"
  description         = "Executa todos os dias às 06:00 UTC (03:00 America/Sao_Paulo)"
  schedule_expression = "cron(0 6 * * ? *)"
}

# Target: invoca a Lambda com o payload desejado
resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.daily_3am_brt_as_utc.name
  target_id = "lambda"
  arn       = data.aws_lambda_function.target.arn

  # Payload enviado para a Lambda
  input = jsonencode({
    transactionreport = "transactionreport"
  })
}

# Permissão para o EventBridge invocar a Lambda
resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromEventBridgeDaily3am"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.target.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_3am_brt_as_utc.arn
}
