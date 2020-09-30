output "vpc" {
    value = aws_vpc.metabase-vpc
    description = "VPC Info"
}


output "json" {
    value = replace(local.table_mapping, "\\n", "")
}
