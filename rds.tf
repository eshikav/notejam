resource "aws_db_subnet_group" "rdsSubnetGroup" {
  name       = "rds-subnet-group"
  subnet_ids = [for key,value in aws_subnet.eksPrivateSubnets: value.id]
  tags = {
    Name = "RDS"
  }
}

resource "aws_db_instance" "rdsInstance" {
  count = var.rdsInfo.useRDSInstance ? 1 : 0
  allocated_storage    = var.rdsInfo.allocated_storage
  engine               = var.rdsInfo.engine
  engine_version       = var.rdsInfo.engine_version
  parameter_group_name = var.rdsInfo.parameter_group_name
  instance_class       = var.rdsInfo.instance_class
  name                 = var.rdsInfo.name
  username             = var.rdsInfo.username
  password             = var.rdsInfo.password
  skip_final_snapshot  = var.rdsInfo.skip_final_snapshot
  multi_az             = var.rdsInfo.multi_az
  port                 = var.rdsInfo.port
  max_allocated_storage= var.rdsInfo.max_allocated_storage
  iops                 = var.rdsInfo.max_allocated_storage
  vpc_security_group_ids = [aws_security_group.eksSecGroup.id]
  db_subnet_group_name = aws_db_subnet_group.rdsSubnetGroup.name
}
