#Foodmart Clickhouse Docker Image#

This image is used in Pantheon test pipeline.

## File Description ##

*data* - Contains Foodmart DB data created in the following manner:

```bash
# in the root of foodmart-data
javac -cp ./libs/*:./drivers/* myfoodmart/MyFoodmart.java
# run the loader
./FoodMartLoader.sh --db clickhouse
```

*docker_related_config.xml* - Taken from Clickhous repo. Used in the official CH Docker image.

*users.xml* - Contains 'foodmart' user definition.

## Building the Image ##

```bash
docker build -f Clickhouse-Dockerfile -t eu.gcr.io/contiamo.com/contiamo/pantheon-db:foodmart-clickhouse .
```

## Running the Image ##

The image can be run with the following command:

* With logs to STDOUT: *

```bash
docker run -p 8123:8123 -ti --rm --name foodmart-clickhouse --ulimit nofile=262144:262144 eu.gcr.io/contiamo.com/contiamo/pantheon-db:foodmart-clickhouse
```

* In Detached Mode:*

```bash
docker run -p 8123:8123 -d --name foodmart-clickhouse --ulimit nofile=262144:262144 eu.gcr.io/contiamo.com/contiamo/pantheon-db:foodmart-clickhouse
```

## COnnecting to Container with CH CLient:##

```bash
docker run -it --rm --link foodmart-clickhouse:foodmart-clickhouse yandex/clickhouse-client --host foodmart-clickhouse
```
