#!/bin/bash

docker pull store/saplabs/hanaexpress:2.00.036.00.20190223.1
wget  https://raw.githubusercontent.com/gdraheim/docker-copyedit/master/docker-copyedit.py
chmod +x docker-copyedit.py
./docker-copyedit.py FROM store/saplabs/hanaexpress:2.00.036.00.20190223.1 INTO my-clean-hana REMOVE ALL VOLUMES

docker rmi -f temp-hana-image
docker build -t temp-hana-image .

docker rm temp-hana-container

docker run -d --hostname hana-db-server -p 39013:39013 -p 39017:39017 -p 39041-39045:39041-39045 -p 1128-1129:1128-1129 -p 59013-59014:59013-59014 \
--ulimit nofile=1048576:1048576 \
--sysctl kernel.shmmax=1073741824 \
--sysctl net.ipv4.ip_local_port_range='40000 60999' \
--sysctl kernel.shmmni=524288 \
--sysctl kernel.shmall=8388608 \
--name temp-hana-container \
temp-hana-image \
--passwords-url file:///password.json \
--agree-to-sap-license \
--dont-check-system

echo 'CREATE DB:'
echo '  docker exec -ti temp-hana-container bash'
echo '  hdbsql -i 90 -d SYSTEMDB -u SYSTEM -p YDmB6vVbgUyfDT'
echo '  CREATE DATABASE foodmart SYSTEM USER PASSWORD YDmB6vVbgUyfDT'
echo '  \q'

echo '  hdbsql -i 90 -d foodmart -u SYSTEM -p YDmB6vVbgUyfDT'
echo '  CREATE USER pantheon PASSWORD YDmB6vVbgUyfDT NO FORCE_FIRST_PASSWORD_CHANGE;'
echo '  GRANT USER ADMIN TO pantheon WITH ADMIN OPTION'
echo '  \q'

echo 'TO TEST permissions:'
echo '  hdbsql -i 90 -d foodmart -u pantheon -p YDmB6vVbgUyfDT'


echo 'TO Check DB Port:'
echo '  SELECT DATABASE_NAME, SQL_PORT FROM SYS_DATABASES.M_SERVICES WHERE DATABASE_NAME='FOODMART''

echo 'When the DB is up, go to the root of foodmart directory, unzip the data from the data folder and run:'
echo 'In n the root of foodmart-data:'
echo 'javac -cp ./libs/*:./drivers/* myfoodmart/MyFoodmart.java'
echo 'Run the loader'
echo './FoodMartLoader.sh --db hana'
echo 'Then save the running container with docker commit'

echo 'DB credentials will then be: user: pantheon; Schema: PANTHEON; DB: foodmart'
