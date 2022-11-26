# --- Creates DynamoDB Table --- #
resource "aws_dynamodb_table" "crc_dynamodb_table" {
  name         = "crc-db"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"

  attribute {
    name = "pk"
    type = "S"
  }

  tags = {
    Name        = "cloud-resume-challenge"
    Environment = "production"
  }
}

resource "aws_dynamodb_table_item" "crc_visit_count_item" {
  table_name = aws_dynamodb_table.crc_dynamodb_table.id
  hash_key   = aws_dynamodb_table.crc_dynamodb_table.hash_key

  item = <<ITEM
{
  "pk": {"S": "Visits"},
  "Hits": {"N": "191"}
}
ITEM

  lifecycle {
    ignore_changes = [item]
  }
}


# --- Creates REST API Gateway resource --- #
resource "aws_api_gateway_rest_api" "crc_api" {
  name        = "CloudResumeAPI"
  description = "Cloud Resume Challenge API Gateway"
}


# --- OPTIONS resources --- #

# --- This module *may* be able to configure OPTIONS/CORS resource automatically --- #
# module "cors" {
#   source = "squidfunk/api-gateway-enable-cors/aws"
#   version = "0.3.3"

#   api_id          = aws_api_gateway_rest_api.crc_api.id
#   api_resource_id = aws_api_gateway_resource.post_resource.id
# }
# -----------------------------------------------------------------------------------#

resource "aws_api_gateway_method" "crc_options_method" {
  rest_api_id      = aws_api_gateway_rest_api.crc_api.id
  resource_id      = aws_api_gateway_resource.post_resource.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.crc_api.id
  resource_id = aws_api_gateway_resource.post_resource.id
  http_method = aws_api_gateway_method.crc_options_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [aws_api_gateway_method.crc_options_method]
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id          = aws_api_gateway_rest_api.crc_api.id
  resource_id          = aws_api_gateway_resource.post_resource.id
  http_method          = aws_api_gateway_method.crc_options_method.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = "{ 'statusCode': 200 }"
  }

  depends_on = [aws_api_gateway_method.crc_options_method]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.crc_api.id
  resource_id = aws_api_gateway_resource.post_resource.id
  http_method = aws_api_gateway_method.crc_options_method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.response_200]
}


# --- POST resources --- #
resource "aws_api_gateway_resource" "post_resource" {
  rest_api_id = aws_api_gateway_rest_api.crc_api.id
  parent_id   = aws_api_gateway_rest_api.crc_api.root_resource_id
  path_part   = "counter"
}

resource "aws_api_gateway_method" "crc_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.crc_api.id
  resource_id   = aws_api_gateway_resource.post_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "post_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.crc_api.id
  resource_id = aws_api_gateway_resource.post_resource.id
  http_method = aws_api_gateway_method.crc_post_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [aws_api_gateway_method.crc_post_method]
}

resource "aws_api_gateway_integration" "post_count_integration" {
  rest_api_id             = aws_api_gateway_rest_api.crc_api.id
  resource_id             = aws_api_gateway_resource.post_resource.id
  http_method             = aws_api_gateway_method.crc_post_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.add_count_lambda.invoke_arn

  depends_on = [aws_api_gateway_method.crc_post_method, aws_lambda_function.add_count_lambda]
}

resource "aws_api_gateway_deployment" "crc_api_deployment_post" {
  rest_api_id = aws_api_gateway_rest_api.crc_api.id
  stage_name  = "prod"

  depends_on = [aws_api_gateway_integration.post_count_integration]
}

resource "aws_api_gateway_method_settings" "post_count" {
  rest_api_id = aws_api_gateway_rest_api.crc_api.id
  stage_name  = aws_api_gateway_deployment.crc_api_deployment_post.stage_name
  method_path = "${aws_api_gateway_resource.post_resource.path_part}/${aws_api_gateway_method.crc_post_method.http_method}"

  settings {}
}


# --- Configuring and provisioning lambda function --- #
resource "aws_iam_role" "crc_lambda_iam_role_iac" {
  name               = "crc-lambda-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_for_dynamo_db" {
  role       = aws_iam_role.crc_lambda_iam_role.name
  policy_arn = "arn:aws:iam::241568881065:policy/LambdaForDynamoDB"
}

resource "aws_lambda_function" "add_count_lambda" {
  filename         = "add_count.zip"
  function_name    = "crc-add-count-function"
  role             = aws_iam_role.crc_lambda_iam_role.arn
  handler          = "add_count.add_count_handler"
  source_code_hash = data.archive_file.add_count_zip.output_base64sha256
  runtime          = "python3.9"
}

resource "aws_lambda_permission" "add_count_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_count_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.crc_api.execution_arn}/*/${aws_api_gateway_method.crc_post_method.http_method}/counter"
}
