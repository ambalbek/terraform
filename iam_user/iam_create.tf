provider "aws" {
    region = "us-east-1"
}
resource "aws_iam_user" "example" {
  count = "${length(var.usernames)}"
  name = "${element(var.usernames,count.index )}"
}