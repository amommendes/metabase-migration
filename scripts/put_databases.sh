#! /bin/bash

echo Admin username:
read username
echo Admin password:
read password

data='{"username": "username_value", "password": "password_value"}'
data=$(echo $data | sed -e "s/username_value/${username}/g")
data=$(echo $data | sed -e "s/password_value/${password}/g")
echo $data > ./token.data 
cat token.data
curl -X POST -H  'Content-Type: application/json' -d @token.data  http://localhost:3000/api/session > token_session.data
token=`cat token_session.data | cut -d ":" -f2 | cut -d "}" -f1` 
rm -rf token.data token_session.data

curl -X POST \
    -H "Content-Type: application/json" \
    -b "metabase.SESSION=$token;" \
    -d '{"engine":"mysql","name":"mysql","details":{"host":"mysql-db","port":3306,"dbname":"metabase","user":"metabase","password":"changeme","tunnel-port":22}}' http://localhost:3000/api/database


curl -X POST \
    -H "Content-Type: application/json" \
    -b "metabase.SESSION=$token;" \
    -d '{"engine":"postgres","name":"psql","details":{"host":"postgres-db","port":5432,"dbname":"metabase","user":"metabase","password":"changeme","tunnel-port":22}}' http://localhost:3000/api/database

