# ./ec2/main.tf
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "test_instance" {
  ami           = "ami-0c55b159cbfafe1f0" # Example AMI ID
  instance_type = "t2.micro"

  tags = {
    Name = "test-instance"
  }
}

output "instance_ids" {
  value = aws_instance.example.*.id
}