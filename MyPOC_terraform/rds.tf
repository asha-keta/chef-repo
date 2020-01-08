resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rds-subnet-group"
  description = "RDS subnet group"
  subnet_ids  = ["${aws_subnet.private_3_subnet_eu_west_1b.id}","${aws_subnet.private_2_subnet_eu_west_1a.id}"]
}
resource "aws_security_group" "rds_sg" {
  name = "rds-sg"
  description = "db Security Group"
  vpc_id = "${aws_vpc.vpc_tuto.id}"

  // allows traffic from the SG itself
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = true
  }

  //allow traffic for TCP 5432
  ingress {
      from_port = 5432
      to_port   = 5432
      protocol  = "tcp"
      }

  // outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_instance" "postgresSQL_db" {
  allocated_storage = 5
  engine            = "postgres"
  engine_version    = "9.5.4"
  instance_class    = "db.m3.medium"
  name              = "testdb"
  username          = "testdbadmin"
  password          = "Password123"
  storage_type                = "gp2"
  multi_az                    = true
  publicly_accessible         = true
  storage_encrypted           = true
  auto_minor_version_upgrade  = false
  allow_major_version_upgrade = false
  db_subnet_group_name   = "${aws_db_subnet_group.rds_subnet_group.id}"
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  backup_retention_period     = 7
  skip_final_snapshot = true
  apply_immediately = ""

  tags {
    Creator = "terraform"
  }
}
