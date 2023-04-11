#backend configuration
terraform {
  backend "s3" {
    bucket = "terraform-sachin-s3-bucket"
    key = "terraform.tfstate"
    region = "ap-southeast-1"
    dynamodb_table = "terraform-sachin-s3-table"
  }
}