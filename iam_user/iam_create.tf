provider "aws" {
    region = "us-east-1"
}
resource "aws_iam_user" "example" {
  count = 10#"${length(var.usernames)}"
  name = "terraform.${count.index+1}"
}
