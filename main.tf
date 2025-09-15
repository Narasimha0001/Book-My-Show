provider "aws" {
  region = "eu-west-3"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }

  required_version = ">= 1.3.0"
}

# ---- Jenkins Security Group ----
resource "aws_security_group" "jenkins_sg" {
  name        = "narasimha-jenkins-sg"
  description = "Allow Jenkins + SSH access"
  vpc_id      = "vpc-0d1c5420a6c0c5f79" 

  ingress {
    description = "Jenkins UI & Prometheus Metrics"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---- Jenkins EC2 Instance ----
resource "aws_instance" "jenkins" {
  ami           = "ami-075d35647275e3501"
  instance_type = "t3.medium"
  subnet_id     = "subnet-03980fab5b6870373" 
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name      = "Narasimha" 

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y java-17-amazon-corretto git wget

    # Install Jenkins
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    dnf install -y jenkins

    systemctl enable jenkins
    systemctl start jenkins

    # Install Docker
    dnf install -y docker
    systemctl enable docker
    systemctl start docker
    usermod -aG docker jenkins
    usermod -aG docker ec2-user
  EOF

  tags = {
    Name = "narasimha-jenkins"
  }
}

# ---- Outputs ----
output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins.public_ip}:8080"
}
