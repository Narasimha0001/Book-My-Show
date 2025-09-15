provider "aws" {
  region = "eu-west-3"  # Paris region
}

# Security Group for Jenkins + SonarQube server
resource "aws_security_group" "narasimha_sg" {
  name        = "narasimha-sg"
  description = "Allow SSH, Jenkins, SonarQube, and Docker"
  vpc_id      = "vpc-0d1c5420a6c0c5f79"  # Clahan-VPC

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Docker UI"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SonarQube UI"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins Agent (JNLP)"
    from_port   = 50000
    to_port     = 50000
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

resource "aws_instance" "narasimha_instance" {
  ami                         = "ami-02d7ced41dff52ebc" # Ubuntu 22.04 LTS
  instance_type               = "t3.large"              # SonarQube needs >2GB RAM
  subnet_id                   = "subnet-0448c551abe9d8da1"
  vpc_security_group_ids      = [aws_security_group.narasimha_sg.id]
  key_name                    = "Narasimha"
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              exec > /var/log/user-data.log 2>&1
              set -e

              echo "==== Updating system ===="
              apt-get update -y

              echo "==== Installing Java 17 ===="
              apt-get install -y openjdk-17-jdk

              echo "==== Adding Jenkins repo ===="
              curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
                /usr/share/keyrings/jenkins-keyring.asc > /dev/null
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
                https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
                /etc/apt/sources.list.d/jenkins.list > /dev/null

              echo "==== Installing Jenkins ===="
              apt-get update -y
              apt-get install -y jenkins

              echo "==== Starting Jenkins ===="
              systemctl enable jenkins
              systemctl start jenkins

              echo "==== Installing Docker ===="
              apt-get install -y docker.io
              systemctl enable docker
              systemctl start docker
              usermod -aG docker jenkins

              echo "==== Installing Git & NodeJS ===="
              apt-get install -y git nodejs npm

              echo "==== Installing SonarQube (via Docker) ===="
              docker run -d --name sonarqube \
                -p 9000:9000 \
                sonarqube:lts

              echo "==== Setup complete! ===="
              EOF

  tags = {
    Name = "Narasimha-Jenkins-SonarQube-Server"
  }
}

output "jenkins_server_public_ip" {
  value = aws_instance.narasimha_instance.public_ip
}
