### provider block......
provider "aws" {
  region  = "us-east-1"
  profile = "josh"
}

terraform {
  backend "s3" {
    bucket         = "terraform-remote-state-vlad-mentorship"
    key            = "terraform.tfstate"
    dynamodb_table = "terraform-remote-state-vlad-mentorship"
    region         = "us-east-1"
    profile        = "josh"
  }

}
