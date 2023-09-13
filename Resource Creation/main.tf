provider "aws" {
    region = "us-east-1"
    access_key = "AKIAVVWQTRKMDHVLJKD3"
    secret_key = "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"

}
resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "puplic-sub" {
  vpc_id = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"
}
resource "aws_security_group" "sc-group" {
  vpc_id = aws_vpc.vpc1.id
  ingress {
    from_port = 22
    to_port = 22
    protocol= "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
  }
}
  
resource "aws_instance" "ec2_test"{
    ami = "ami-01c647eace872fc02"
    instance_type = "t2.micro"  
    subnet_id = aws_subnet.puplic-sub.id 
}
terraform {
  backend "s3" {
    bucket = "state-bucket-kiran"
    key = "key/terraform/terraform.tfstate"
    encrypt = true
    region = "us-east-1"
    dynamodb_table = "table-statefile"

  }
}
---
# Enable encryption SSE-S3 for S3 Bucket

resource "aws_s3_bucket" "bucket" {
  bucket = "my_tfstate_bucket"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
