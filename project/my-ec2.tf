provider "aws" {
  region     = "us-east-1"
}
resource "aws_instance" "example" {
    ami = "ami-09d95fab7fff3776c"
    instance_type = "t2.micro"
    key_name = "virginia"
    count = 5

# add
    user_data = <<-EOF
                #! /bin/bash
                sudo yum update
                sudo yum install -y httpd
                sudo yum install python3 -y
                sudo chkconfig httpd on
                sudo service httpd start
                sudo echo "<h1>Salam Dunya!</h1>" > /var/www/html/index.html
                EOF

    tags = {
        Name = "terraform-example.${count.index+1}"
    }
}