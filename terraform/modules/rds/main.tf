resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Allow MySQL traffic from EKS nodes only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EKS cluster security group"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [var.eks_cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rds-sg"
  })
}

resource "aws_db_instance" "this" {
  identifier             = "${var.name_prefix}-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  storage_type           = "gp3"
  db_name                = var.database_name
  username               = var.admin_username
  password               = var.admin_password
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds.id]
  multi_az               = var.multi_az
  backup_retention_period = 1
  skip_final_snapshot    = var.skip_final_snapshot
  publicly_accessible    = false
  storage_encrypted      = true
  deletion_protection    = var.deletion_protection

  tags = var.tags
}
