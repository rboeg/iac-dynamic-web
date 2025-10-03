# ----------------------------
# AWS Provider
# ----------------------------
provider "aws" {
  region  = var.aws_region
  profile = length(var.aws_profile) > 0 ? var.aws_profile : null
}

# ----------------------------
# SSM Parameter
# ----------------------------
resource "aws_ssm_parameter" "tf_dyn_web_param" {
  name  = var.parameter_name
  type  = "String"
  value = "dynamic string" # default value
}

# ----------------------------
# IAM Role for Lambda
# ----------------------------
resource "aws_iam_role" "tf_dyn_web_lambda_exec" {
  name = "tf_dyn_web_lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach permissions so Lambda can read from SSM
resource "aws_iam_role_policy_attachment" "tf_dyn_web_lambda_ssm" {
  role       = aws_iam_role.tf_dyn_web_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

# Attach basic Lambda execution permissions (logs, etc.)
resource "aws_iam_role_policy_attachment" "tf_dyn_web_lambda_basic" {
  role       = aws_iam_role.tf_dyn_web_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ----------------------------
# Lambda Function
# ----------------------------
resource "aws_lambda_function" "tf_dyn_web_lambda" {
  function_name = "tf_dyn_web_lambda"
  role          = aws_iam_role.tf_dyn_web_lambda_exec.arn
  runtime       = "python3.12"
  handler       = "app.lambda_handler"

  filename         = local.lambda_zip_path
  source_code_hash = filebase64sha256(local.lambda_zip_path)

  environment {
    variables = {
      PARAM_NAME = aws_ssm_parameter.tf_dyn_web_param.name
    }
  }
}

# ----------------------------
# API Gateway
# ----------------------------
resource "aws_apigatewayv2_api" "tf_dyn_web_api" {
  name          = var.api_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "tf_dyn_web_integration" {
  api_id           = aws_apigatewayv2_api.tf_dyn_web_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.tf_dyn_web_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "tf_dyn_web_route" {
  api_id    = aws_apigatewayv2_api.tf_dyn_web_api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.tf_dyn_web_integration.id}"
}

resource "aws_apigatewayv2_stage" "tf_dyn_web_stage" {
  api_id      = aws_apigatewayv2_api.tf_dyn_web_api.id
  name        = "$default"
  auto_deploy = true
}

# Allow API Gateway to call Lambda
resource "aws_lambda_permission" "tf_dyn_web_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tf_dyn_web_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.tf_dyn_web_api.execution_arn}/*/*"
}
