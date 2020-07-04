provider "aws" {
  region     = "us-east-1"
}
resource "aws_instance" "example" {
    ami = "ami-09d95fab7fff3776c"
    instance_type = "t2.micro"
    key_name = "virginia"
    iam_instance_profile = "jenkins"
    count = 1

# add
    user_data = <<-EOF
                #! /bin/bash
                sudo yum update -y
                sudo yum install httpd -y
                sudo systemctl start httpd
                sudo systemctl enable httpd
                sudo yum install python3 -y
                sudo pip3 install django
                sudo pip3 install psycopg2-binary
                sudo pip3 install pillow
                mkdir django
                cd django
                aws s3 sync s3://akmana/ /home/ec2-user/django
                python3 manage.py runserver self.public_ip:8000
                EOF

    tags = {
        Name = "terraform-example.${count.index+1}"
    }
}