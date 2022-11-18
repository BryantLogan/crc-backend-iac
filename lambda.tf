# # --- Configuring and provisioning lambda functions ---

# resource "aws_iam_role" "crc_lambda_iam_role" {
#   name               = "crc-lambda-iam"
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts.AssumeRole",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": "*"
#     }
#   ]
# }
#   EOF
# }

# resource "aws_lambda_function" "get_count_lambda" {
#   filename         = "get_count.zip"
#   function_name    = "crc-get-count-function"
#   role             = aws_iam_role.crc_lambda_iam_role.arn
#   handler          = "lambda.lambda_handler"
#   source_code_hash = data.archive_file.get_count_zip.output_base64sha256
#   runtime          = "python3.9"
# }

# resource "aws_lambda_function" "add_count_lambda" {
#   filename         = "add_count.zip"
#   function_name    = "crc-add-count-function"
#   role             = aws_iam_role.crc_lambda_iam_role.arn
#   handler          = "lambda.lambda_handler"
#   source_code_hash = data.archive_file.add_count_zip.output_base64sha256
#   runtime          = "python3.9"
# }