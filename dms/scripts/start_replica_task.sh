
echo Getting ARN from replication task
aws dms describe-replication-tasks --filters "Name=replication-task-id,Values=dms-metabase-task" > ./resources/task-data.json
chmod 775 dms/resources/task-data.json
ARN=`jq '.ReplicationTasks[0].ReplicationTaskArn' ./resources/task-data.json | sed  "s/\"//g"`
echo ARN=$ARN
aws dms start-replication-task --replication-task-arn=$ARN --start-replication-task-type=start-replication