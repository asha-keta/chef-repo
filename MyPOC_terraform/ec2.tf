# security group for EC2 instances
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sq"
  description = "allow incoming HTTP traffic only"
  vpc_id      = "${aws_vpc.vpc_tuto.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instances in public subnet web
resource "aws_instance" "web" {
  ami                         = "ami-08660f1c6fb6b01e7"
  associate_public_ip_address = true
  depends_on                  = ["aws_subnet.public_subnet_eu_west_1a"]
  instance_type               = "t2.micro"
  key_name                    = "asha_eu"
  subnet_id                   = "${aws_subnet.public_subnet_eu_west_1a.id}"
  user_data                   = "${file("user_data.sh")}"

  # references security group created above
  vpc_security_group_ids = ["${aws_security_group.ec2_sg.id}"]

  tags {
    Name = "public_instance_web"
  }
}

# EC2 instances in public subnet app
resource "aws_instance" "app" {
  ami                         = "ami-08660f1c6fb6b01e7"
  associate_public_ip_address = true
  depends_on                  = ["aws_subnet.private_1_subnet_eu_west_1a"]
  instance_type               = "t2.micro"
  key_name                    = "asha_eu"
  subnet_id                   = "${aws_subnet.private_1_subnet_eu_west_1a.id}"
  user_data                   = "${file("user_data1.sh")}"

  # references security group created above
  vpc_security_group_ids = ["${aws_security_group.ec2_sg.id}"]

  tags {
    Name = "private_instance_app"
  }
}
