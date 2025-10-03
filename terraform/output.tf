# ----------------------------
# API Gateway URL
# ----------------------------
output "tf_dyn_web_api_url" {
  description = "Invoke URL of the dynamic web API Gateway"
  value       = aws_apigatewayv2_stage.tf_dyn_web_stage.invoke_url
}
