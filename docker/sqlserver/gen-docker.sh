#!/bin/bash

# Test with:
#
#     bash gen-docker.sh || (docker stop mssql-temp; docker rm mssql-temp)
#
# If successful, this will save a fresh sqlserver+foodmart image to the local container storage.
# Upload with `docker push`.

DOCKER_SRC_IMG=mcr.microsoft.com/mssql/server:2017-latest
DOCKER_TARGET_IMG=eu.gcr.io/dev-and-test-env/foodmart-mssql:v0.0.3
SA_PASSWORD=my_SA_pwd
TEMP_CONTAINER=mssql-temp

# must match init.sql
USER_USER=foodmart
USER_PASSWORD=F00dmartpass

docker version > /dev/null || exit 1

( docker ps -a | grep -w $TEMP_CONTAINER ) && { echo "Temporary container $TEMP_CONTAINER already exists"; exit 1; } || true

set -xe

# Start the Docker container
docker run -e 'ACCEPT_EULA=Y' -e "SA_PASSWORD=$SA_PASSWORD" -p 127.0.0.1:1433:1433 --name $TEMP_CONTAINER -d mcr.microsoft.com/mssql/server:2017-latest

# Recommended by Microsoft, don't know why
docker exec -it $TEMP_CONTAINER /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $SA_PASSWORD -Q "ALTER LOGIN SA WITH PASSWORD='$SA_PASSWORD'"

# Initialise login, db, user; strip comments from init.sql
docker exec -it $TEMP_CONTAINER /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $SA_PASSWORD -Q "$(grep -v ^\\s*-- init.sql )"

# Load data
../../FoodMartLoader.sh --db sqlserver --db-host localhost --db-user $USER_USER --db-pass $USER_PASSWORD

docker stop $TEMP_CONTAINER

docker commit mssql-temp $DOCKER_TARGET_IMG

docker rm $TEMP_CONTAINER
