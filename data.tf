# --- Packages python files into .zip to be used by Lambda functions --- #
data "archive_file" "add_count_zip" {
  type        = "zip"
  source_file  = "add_count.py"
  output_path = "add_count.zip"
}

data "archive_file" "get_count_zip" {
  type        = "zip"
  source_file  = "get_count.py"
  output_path = "get_count.zip"
}