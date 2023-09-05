# store the terraform state file in s3
terraform {
  backend "s3" {
    bucket    = "iac-jenkins-tfstate"
    key       = "terraform.tfstate"
    region    = "us-east-1"
    profile = "Codebuild-user"
    dynamodb_table = "iac-jenkins-tfstate-db-table"
  }
}