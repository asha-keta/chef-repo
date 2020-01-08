resource "aws_efs_file_system" "efs-example" {
   creation_token = "efs-example"
   performance_mode = "generalPurpose"
   throughput_mode = "bursting"
   encrypted = "true"
 tags = {
     Name = "EfsExample"
   }
 }

 resource "aws_efs_mount_target" "efs-mt-example" {
   file_system_id  = "${aws_efs_file_system.efs-example.id}"
   subnet_id = "${aws_subnet.subnet-efs.id}"
   security_groups = ["${aws_security_group.ingress-efs.id}"]
 }

 resource "aws_security_group" "ingress-efs" {
   name = "ingress-efs-test-sg"
   vpc_id = "${aws_vpc.vpc_tuto.id}"

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
 resource "aws_subnet" "subnet-efs" {
   cidr_block = "${cidrsubnet(aws_vpc.vpc_tuto.cidr_block, 8, 8)}"
   vpc_id = "${aws_vpc.vpc_tuto.id}"
   availability_zone = "eu-west-1a"
 }
