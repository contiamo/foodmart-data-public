#!/bin/bash

docker pull eu.gcr.io/dev-and-test-env/oracle-database:18.4.0-xe

wget  https://raw.githubusercontent.com/gdraheim/docker-copyedit/master/docker-copyedit.py
chmod +x docker-copyedit.py

./docker-copyedit.py FROM eu.gcr.io/dev-and-test-env/oracle-database:18.4.0-xe INTO no-volume-oracle:18.4.0-xe REMOVE ALL VOLUMES

docker rm oracle-clean-temp-container
docker run -ti --name -d oracle-clean-temp-container -p 1521:1521 -e ORACLE_PWD=1qaz2wsx3edc no-volume-oracle:18.4.0-xe

echo "TO Import DB: "
echo "docker exec -ti oracle-clean-temp-container bash"

echo "sqlplus"
echo "User: SYSTEM"
echo "Pass: 1qaz2wsx3edc"
echo 'alter session set "_ORACLE_SCRIPT"=true;'
echo 'alter session set container=XEPDB1;'
echo 'grant all privileges to PDBADMIN identified by "1qaz2wsx3edc"'
echo 'commit'

echo '../../FoodMartLoader.sh  --db oracle --db-pass 1qaz2wsx3edc'

echo 'docker commit oracle-clean-temp-container  eu.gcr.io/dev-and-test-env/foodmart-oracle:v2.0.0'
echo 'docker push  eu.gcr.io/dev-and-test-env/foodmart-oracle:v2.0.0

