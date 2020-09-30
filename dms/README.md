### AWS DMS with terraform

You can use these terraform files to create all resources needed to simultate Metabase database migration using AWS DMS.

What resources will be created?

- VPC (with security groups inbound rules to your IP, internet gateways, two subnets, subnet group, route tables)
- Database instances
- DMS (An replication instance, endpoints and a replication task)

*All resources are free tier (micro instances)*

How to run?

1. [Set your AWS credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) 

2. Plan your provisioning

*You can create a tfvar file with your database secrets or input when running terraform commands*

```shell
terraform plan -var-file my-secret-file.tfvars
```

3. Provisioning

```shell
terraform apply -var-file my-secret-file.tfvars
```

4. Change your Metabase container env files to point out to your new databases

5. Start Metabase in your MySQL and play around with questions, dashboards and so on

6. Prepare your Metabase using Postgres:

- 6.1 Get migrations scripts using Metabase migration utility

```
MB_DB_CONNECTION_URI=postgres://MY-AWS-POSTGRES-ENDPOINT:5432/metabase?user=MYUSER&password=changeme&currentSchema=metabase
java -jar metabase.jar migrate force
```

You can run migrations manually using the `print` metabase migrate command to get SQL statement to execute all database steps

7. Run migration task

```
sh scripts/start_replica_task.sh
```

8. Wacth the migration task in the AWS Console and CloudWatch logs 


