FoodMart Data Loader
=============================

A wrapper to the Mondrian FoodMart Data Loader

INTRO
-----------------------------

This is a small wrapper to the Mondrian FoodMart Data Loader, the JAR files
were taken It takes the FoodMart SQL Creation script and loads the data onto
the database of your choice.

The script is easily editable to add additional database options.
As is the script assumes that all database servers are running on the local
machine, this can be edited before running the wrapper script.

Drivers that are included on this version are:
- ProstgreSQL
- MySQL
- SQL Server
- Sybase
- DB2
- Oracle
- Teradata


Pre-requistes:
------------------------------
- Make sure you have a Java 7 or later in your PATH.
- Choose one of the following `db_types`:
    + mysql
    + postgres
    + sqlserver
    + sybase
    + db2
    + oracle
    + teradata

Usage Instructions
------------------------------
Run the script as follows:

```
./FoodMartLoader.sh --db <db_type> [--db-host <db_host>] [--db-user <db_user>] [--db-pass <db_pass>]
```

In case of Oracle DB loader will load data into Pluggable DB (PDB) under name
`XEPDB1`, which is default PDB name for official Oracle Docker image.

Running in cluster
------------------------------
One option is to run loader inside the cluster to speedup import process
significantly.

It is possible with included `Dockerfile`, first images should be built and
uploaded to your registry.

```
docker build . -t <your-registry-path>:latest
docker push <your-registry-path>:latest
```

Then, you can start loader like this:

```
kubectl run --image <your-registry-path>:latest --restart=Never foodmart-data -- <FoodMartLoader.sh parameters>
```

Don't forget to delete pod once import will be done.
