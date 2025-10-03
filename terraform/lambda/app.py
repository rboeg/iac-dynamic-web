import boto3
import os

# Initialize the SSM client
ssm = boto3.client("ssm")

def lambda_handler(event, context):
    # Default parameter path
    param_name = os.environ.get("PARAM_NAME", "/tf_dyn_web/message")
    
    # Fetch the value from SSM Parameter Store
    response = ssm.get_parameter(Name=param_name)
    message = response["Parameter"]["Value"]

    # Build the HTML response
    html = f"<h1>The saved string is {message}</h1>"

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "text/html"},
        "body": html
    }
