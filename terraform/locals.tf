locals {
  # Full path to the Lambda zip file
  lambda_zip_path = "${path.module}/../lambda_build/${var.lambda_zip_name}"
}
