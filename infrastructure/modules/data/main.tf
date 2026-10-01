resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnets"
  }
}

resource "aws_security_group" "mysql" {
  name        = "${var.project_name}-${var.environment}-mysql-sg"
  description = "Allows MySQL traffic only from the EKS cluster."
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EKS workloads"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_cluster_security_group_id]
  }

  egress {
    description = "Required outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-mysql-sg"
  }
}

resource "aws_db_instance" "mysql" {
  identifier = "${var.project_name}-${var.environment}-mysql"

  engine         = "mysql"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true

  db_name  = "retail"
  username = "retailadmin"

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.mysql.id]
  publicly_accessible    = false

  backup_retention_period = 7
  copy_tags_to_snapshot   = true

  multi_az            = false
  deletion_protection = false
  skip_final_snapshot = true
  apply_immediately   = false

  tags = {
    Name = "${var.project_name}-${var.environment}-mysql"
  }
}

resource "aws_dynamodb_table" "inventory" {
  name         = "${var.project_name}-${var.environment}-inventory"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "productId"

  attribute {
    name = "productId"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }
}

resource "aws_dynamodb_table" "notification" {
  name         = "${var.project_name}-${var.environment}-notification"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "notificationId"

  attribute {
    name = "notificationId"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }
}