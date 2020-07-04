provider "aws" {
    region = "us-east-1"
}

resource "aws_iam_role" "terraform_ec2fullaccess" {
  name = "terraform_ec2fullaccess"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "tag-value"
  }
}
resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = "${aws_iam_role.terraform_ec2fullaccess.name}"
}
resource "aws_iam_role_policy" "terraform_ec2fullaccess" {
  name = "terraform_ec2fullaccess"
  role = "${aws_iam_role.terraform_ec2fullaccess.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "ec2:*",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "cloudwatch:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "autoscaling.amazonaws.com",
                        "ec2scheduled.amazonaws.com",
                        "elasticloadbalancing.amazonaws.com",
                        "spot.amazonaws.com",
                        "spotfleet.amazonaws.com",
                        "transitgateway.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
EOF
}
resource "aws_instance" "role-test" {
  ami = "ami-09d95fab7fff3776c"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
  key_name = "virginia"
  count = 10
  tags = {
    Name = "terraform-example.${count.index+1}"
  }
}