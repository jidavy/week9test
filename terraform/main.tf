terraform {
  backend "s3" {
    bucket         = "texxclass" 
    key            = "terraform/state.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    # Note: It is highly recommended to add dynamodb_table here for state locking!
  }

  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region # Using variable
}

#-------------------------------------
#SECURITY GROUPS
#-------------------------------------

resource "aws_security_group" "jigzy_sg" {
  name        = "multi-node-security-group"
  description = "Security group for Java, Nginx, and Ansible nodes"

  # 1. SSH (Port 22) - Required for all 3 nodes so YOU can log in
  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 2. HTTP (Port 80) - Specifically for the Nginx Node
  ingress {
    description = "Allow HTTP for Nginx"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 3. Java App (Port 8080) - Specifically for the Java Node
  ingress {
    description = "Allow Java App traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 4. Outbound Traffic - Required for Ansible to manage other nodes
  # And for all nodes to download updates from the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allows all traffic OUT
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Main-App-SG"
  }
}

#-------------------------------------
# HARD CODED AWS INSTANCES
#-------------------------------------

# 1. Java Node
resource "aws_instance" "java_node" {
  ami                    = "ami-0c38b837e2b6d452a"
  instance_type          = "t3.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jigzy_sg.id] # Attached here
  tags = { Name = "Java Node" }
}

# 2. Nginx Node (Updated with User Data)
resource "aws_instance" "nginx_node" {
  ami                    = "ami-0c38b837e2b6d452a"
  instance_type          = "t3.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jigzy_sg.id]

  user_data = file("${path.module}/install_nginx.sh")
  
  tags = { Name = "Nginx Node" }
}

# 3. Ansible Server
resource "aws_instance" "ansible_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jigzy_sg.id]

  user_data = file("${path.module}/install_ansible.sh")

  tags = { Name = "Ansible Server" }
}

#-------------------------------------
# OUTPUTS (Optional but helpful)
#-------------------------------------

output "java_node_ip" {
  value = aws_instance.java_node.public_ip
}

output "nginx_node_ip" {
  value = aws_instance.nginx_node.public_ip
}

output "ansible_server_ip" {
  value = aws_instance.ansible_server.public_ip
}

