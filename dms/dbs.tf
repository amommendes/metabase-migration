resource "aws_db_instance" "metabase-mysql" {
  
  engine            = "mysql"
  engine_version    = "5.7.22"
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  storage_encrypted = false
  skip_final_snapshot = true
  identifier = "metabase-mysql"
  name     = "metabase"
  username = "metabase"
  password = var.metabase_pass
  port     = "3306"
  vpc_security_group_ids = [aws_security_group.metabase_sg.id, ]
  backup_retention_period = 1
  backup_window = "06:00-08:00"
  db_subnet_group_name = aws_db_subnet_group.metabase-group.name
  publicly_accessible = true
  tags = aws_vpc.metabase-vpc.tags
  parameter_group_name = aws_db_parameter_group.mysql-rds.name
  apply_immediately  = true
  
}

resource "aws_db_instance" "metabase-psql" {
  
  engine            = "postgres"
  engine_version    = "11.6"
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  storage_encrypted = false
  skip_final_snapshot = true
  identifier = "metabase-postgresql"
  vpc_security_group_ids = [aws_security_group.metabase_sg.id, ]
  
  name     = "metabase"
  username = "metabase"
  password = var.metabase_pass
  port     = "5432"
  publicly_accessible = true
  backup_retention_period = 0
  db_subnet_group_name = aws_db_subnet_group.metabase-group.name
  parameter_group_name = aws_db_parameter_group.postgres-rds.name
  tags = aws_vpc.metabase-vpc.tags
}


resource "aws_db_parameter_group" "mysql-rds" {
    name   = "mysql-rds"
    family = "mysql5.7"

    parameter {
      name  = "character_set_server"
      value = "utf8"
    }

    parameter {
      name  = "binlog_format"
      value = "ROW"
    }

    parameter {
      name  = "character_set_client"
      value = "utf8"
    }

    parameter {
      name = "binlog_checksum"
      value = "NONE"
    }
}

resource "aws_db_parameter_group" "postgres-rds" {
    name   = "postgres-rds"
    family = "postgres11"

    parameter {
        name  = "session_replication_role"
        value = "replica"
      }
}