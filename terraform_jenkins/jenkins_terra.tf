provider "aws" {
  region     = "us-east-1"
}
resource "aws_instance" "example" {
    ami = "ami-09d95fab7fff3776c"
    iam_instance_profile = "jenkins"
    instance_type = "t2.micro"
    key_name = "virginia"
    count = 1

# install Jenkins, Git, Terraform v.11
    user_data = <<-EOF
                #! /bin/bash
                sudo yum update -y
                sudo yum install java-1.8.0-openjdk-devel
                curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo
                sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
                sudo yum install jenkins -y
                sudo systemctl start jenkins
                sudo systemctl enable jenkins
                wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
                sudo unzip ./terraform_0.11.13_linux_amd64.zip -d /usr/local/bin/
                sudo yum install git -y
                
                EOF

    tags = {
        Name = "jenkins.${count.index+1}"
    }
}