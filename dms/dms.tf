
#Policies and roles to use DMS
data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "dms-access-for-endpoint" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-access-for-endpoint"
}

resource "aws_iam_role" "dms-vpc-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-vpc-role"
}

resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms-vpc-role.name
}

resource "aws_iam_role" "dms-cloudwatch-logs-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-cloudwatch-logs-role"
}

resource "aws_iam_role_policy_attachment" "dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
  role       = aws_iam_role.dms-cloudwatch-logs-role.name
}

#Subnet group to DMS

resource "aws_dms_replication_subnet_group" "metabase-replication-group" {
  replication_subnet_group_description = "Metabase replication subnet group"
  replication_subnet_group_id          = "metabase-dms-replication-subnet-group"

  subnet_ids = [
      aws_subnet.metabase-subnet-1.id,
      aws_subnet.metabase-subnet-2.id
    ]

  tags = {
    Name = "metabase"
  }
}

# Replication Instance

resource "aws_dms_replication_instance" "metabase-migrator" {
    allocated_storage            = 20
    apply_immediately            = true
    auto_minor_version_upgrade   = true
    availability_zone = data.aws_availability_zones.available.names[0]
    engine_version               = "3.3.3"
    multi_az                     = false
    publicly_accessible          = true
    replication_instance_class   = "dms.t2.micro"
    replication_subnet_group_id  = aws_dms_replication_subnet_group.metabase-replication-group.id
    replication_instance_id = "metabase-migrator"
    tags = {
        Name = "metabase"
    }

    vpc_security_group_ids = [
        aws_security_group.metabase_sg.id,
    ]
}


resource "aws_security_group_rule" "mysql_rule" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [for ip in aws_dms_replication_instance.metabase-migrator.replication_instance_private_ips: "${ip}/32"]
  security_group_id = aws_security_group.metabase_sg.id
}


resource "aws_security_group_rule" "psql_rule" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = [for ip in aws_dms_replication_instance.metabase-migrator.replication_instance_private_ips: "${ip}/32"]
  security_group_id = aws_security_group.metabase_sg.id
}


# Endpoints

resource "aws_dms_endpoint" "endpoint_mysql" {
    database_name               = aws_db_instance.metabase-mysql.name
    endpoint_id                 = "endpoint-mysql"
    endpoint_type               = "source"
    engine_name                 = aws_db_instance.metabase-mysql.engine
    extra_connection_attributes = ""
    username                    = "metabase"
    password                    = var.metabase_pass
    port                        = aws_db_instance.metabase-mysql.port
    server_name                 = aws_db_instance.metabase-mysql.address
    ssl_mode                    = "none"

    tags = {
      Name = "Metabase migration"
    }


}

resource "aws_dms_endpoint" "endpoint_postgres" {
    database_name               = aws_db_instance.metabase-psql.name
    endpoint_id                 = "endpoint-postgres"
    endpoint_type               = "target"
    engine_name                 = aws_db_instance.metabase-psql.engine
    extra_connection_attributes = ""
    username                    = "metabase"
    password                    = var.metabase_pass
    port                        = aws_db_instance.metabase-psql.port
    server_name                 = aws_db_instance.metabase-psql.address
    ssl_mode                    = "none"

    tags = {
      Name = "Metabase migration"
    }


}


resource "aws_dms_replication_task" "migrate-metabase" {
    migration_type            = "full-load"
    replication_instance_arn  = aws_dms_replication_instance.metabase-migrator.replication_instance_arn
    replication_task_id       = "dms-metabase-task"
    source_endpoint_arn       = aws_dms_endpoint.endpoint_mysql.endpoint_arn
    table_mappings            = local.table_mapping
    replication_task_settings = local.task_settings

    tags = {
      Name = "Metabase Migration"
    }

    target_endpoint_arn = aws_dms_endpoint.endpoint_postgres.endpoint_arn
} 

