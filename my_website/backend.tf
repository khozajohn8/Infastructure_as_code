# store the terraform state file in s3
terraform {
  backend "s3" {
    bucket    = "my-website-terraform-remote-state-jk"
    key       = "build/terraform.tfstate"
    region    = "us-east-1"
    profile = "Codebuild-user"
    dynamodb_table = "my-dynamo-db-table"
  }
}