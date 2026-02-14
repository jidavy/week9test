variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "eu-west-1"
}

variable "ami_id" {
  description = "The Amazon Linux 2023 AMI ID"
  type        = string
  default     = "ami-080ecf65f4d838a6e"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  description = "The name of the SSH key pair created in AWS"
  type        = string
  default     = "jenkins-keys" # Change this to your actual AWS Key Pair name
}
