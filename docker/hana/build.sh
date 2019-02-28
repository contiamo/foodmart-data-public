#!/bin/bash

docker pull store/saplabs/hanaexpress:2.00.036.00.20190223.1
wget  https://raw.githubusercontent.com/gdraheim/docker-copyedit/master/docker-copyedit.py
chmod +x docker-copyedit.py
./docker-copyedit.py FROM store/saplabs/hanaexpress:2.00.036.00.20190223.1 INTO my-clean-hana REMOVE ALL VOLUMES

docker rmi -f temp-hana-image
docker build -t temp-hana-image .

docker rm temp-hana-container

docker run --hostname hana-db-server -p 39013:39013 -p 39017:39017 -p 39041-39045:39041-39045 -p 1128-1129:1128-1129 -p 59013-59014:59013-59014 \
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

# When the DB is up go to the root of foodmart directory, iunzip the data from the data folder and run:
# In n the root of foodmart-data:
# javac -cp ./libs/*:./drivers/* myfoodmart/MyFoodmart.java
# Run the loader
#./FoodMartLoader.sh --db hana
# Then save the running container with docker commit
