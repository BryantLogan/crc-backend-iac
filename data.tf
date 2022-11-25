# --- Packages python files into .zip to be used by Lambda functions --- #
data "archive_file" "add_count_zip" {
  type        = "zip"
  source_dir  = "~\\python\\add_count_function\\"
  output_path = "add_count.zip"
}

data "archive_file" "get_count_zip" {
  type        = "zip"
  source_dir  = "~\\python\\get_count_function\\"
  output_path = "get_count.zip"
}