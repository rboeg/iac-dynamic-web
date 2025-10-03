# iac-dynamic-web
Terraform project to deploy a serverless dynamic web endpoint on AWS.

## 1. Solution Overview
The solution provisions a serverless application on AWS using Terraform. It consists of:

- An **SSM Parameter** that stores a dynamic string.  
- An **AWS Lambda function** that retrieves the parameter and returns an HTML page.  
- An **API Gateway (HTTP API)** that exposes the Lambda via a public URL.  
- Supporting **IAM roles and permissions** to allow secure interactions.  

The HTML page served is:

```html
<h1>The saved string is {dynamic string}</h1>
```

The dynamic string is read at runtime from the SSM Parameter Store.
This allows updates via the AWS CLI or Console without requiring a redeployment of infrastructure or code.
Any user accessing the URL will see the latest saved string.


## 2. How to Use

### Requirements

* Linux or Unix-like environment (tested on Debian).
* Terraform >= 1.6 installed.
* AWS CLI installed and configured with credentials (`aws configure`).
* An AWS account with permissions to use Lambda, API Gateway, and SSM Parameter Store.


### 2.1. Deploy the Infrastructure

Clone the repository and move into the Terraform folder:

```bash
git clone git@github.com:rboeg/iac-dynamic-web.git
cd iac-dynamic-web/terraform
```

Initialize Terraform:

```bash
terraform init
```

Generate and review the execution plan:

```bash
terraform plan
```

Apply the infrastructure with default values:

```bash
terraform apply
```

Or, apply with custom parameters (example):

```bash
terraform apply \
  -var="aws_region=us-east-2" \
  -var="aws_profile=my-aws-profile" \
  -var="parameter_name=/tf_dyn_web/custom_message"
```

When finished, Terraform will output the **API URL**:

```
Outputs:

api_url = "https://aabbccdd.execute-api.us-east-1.amazonaws.com"
```

### 2.2. Test the Endpoint

Open the API URL in your browser. By default, it shows:

```html
<h1>The saved string is dynamic string</h1>
```

### 2.3. Update the Dynamic Message

You can update the dynamic string at runtime using the provided helper script.
No redeployment of infrastructure or code is required.

The script works under the hood by calling the AWS CLI command:

```bash
aws ssm put-parameter --name /tf_dyn_web/message --value "New message" --type String --overwrite
```

This updates the **SSM Parameter Store** value that the Lambda function reads on each request.

#### Usage

Update the message using the default AWS profile:

```bash
./scripts/update_string.sh "New message text"
```

Or, specify an AWS CLI profile:

```bash
./scripts/update_string.sh "Another message" my-aws-profile
```

* **First argument**: the new string to save.
* **Second argument (optional)**: AWS CLI profile name.

After running the script, refresh the API URL in your browser to see the updated string immediately.


### 2.4. Clean Up

To destroy all resources and avoid charges:

```bash
terraform destroy
```

## 3. Documentation

For a detailed explanation of the solution, design decisions, and implementation, see the [full documentation](docs/solution.pdf).
