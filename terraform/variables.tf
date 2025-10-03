variable "aws_region" {
  description = "AWS region to deploy the resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use (optional). If not provided, uses the default/current profile"
  type        = string
  default     = ""
}

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "tf_dyn_web_api"
}

variable "parameter_name" {
  description = "Name of the SSM parameter to store the dynamic message"
  type        = string
  default     = "/tf_dyn_web/message"
}

variable "lambda_zip_name" {
  description = "Filename of the Lambda zip package"
  type        = string
  default     = "tf_dyn_web_lambda.zip"
}
