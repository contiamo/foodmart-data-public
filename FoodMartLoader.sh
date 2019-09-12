#!/bin/bash
#
# This software is subject to the terms of the Eclipse Public License v1.0
# Agreement, available at the following URL:
# http://www.eclipse.org/legal/epl-v10.html.
# You must accept the terms of that agreement to use this software.
#
# Copyright (C) 2014 Meteorite Consulting
# All Rights Reserved.
#
# Sample scripts to load Mondrian's database for various databases.
# Based on https://github.com/pentaho/mondrian/blob/master/bin/loadFoodMart.sh

set -euo pipefail

case $(uname) in
	Linux|Darwin)
		path_separator=":" ;;
	*)
		path_separator=";" ;;
esac

class_paths=("libs/*" "drivers/*" "src")
class_path=$(
	printf "%s\n" "${class_paths[@]}" \
		| paste -sd "$path_separator" -
)

error() {
	echo "Error: $@"
	exit 1
}

configure_db()	{
	case $db in
		(teradata)
			db_driver="com.teradata.jdbc.TeraDriver"
			db_url="jdbc:teradata://${db_host}/DBS_PORT=${db_port:-1025}"
			;;

		(oracle)
			db_user=${db_user:-SYSTEM}
			db_driver="oracle.jdbc.driver.OracleDriver"
			db_url="jdbc:oracle:thin:@//${db_host}:${db_port:-1521}/XEPDB1"
			;;

		(db2)
			db_user=${db_user:-db2inst1}
			db_pass=${db_user:-db2inst1-pwd}
			db_driver="com.ibm.db2.jcc.DB2Driver"
			db_url="jdbc:db2://${db_host}:${db_port:-50000}/foodmart"
			;;

		(mysql)
			db_driver="com.mysql.jdbc.Driver"
			db_url="jdbc:mysql://${db_host}/foodmart"
			;;

		(postgres)
			db_driver="org.postgresql.Driver"
			db_url="jdbc:postgresql://${db_host}/foodmart"
			;;

		(sqlserver)
			db_driver="net.sourceforge.jtds.jdbc.Driver"
			db_url="jdbc:jtds:sqlserver://${db_host}/foodmart"
			# sqlserver has strict password requirements
			;;

		(sybase)
			db_driver="net.sourceforge.jtds.jdbc.Driver"
			db_url="jdbc:jtds:sybase://${db_host}/foodmart"
			;;

		(hana)
			db_driver="com.sap.db.jdbc.Driver"
			db_url="jdbc:sap://${db_host}:39044/?databaseName=foodmart"
			db_user=pantheon
			db_pass=YDmB6vVbgUyfDT
			;;

		('')
			error "You must specify a database."
			;;

		(*)
			error "Unknown database selection."
			;;
	esac

	if [[ ! "${db_user}" ]]; then
		error "Need to specify --db-user for a ${db} database."
	fi

	if [[ ! "${db_pass}" ]]; then
		error "Need to specify --db-pass for ${db_user} user for a ${db} database."
	fi
}

usage() {
	echo "$(basename $0) - import FoodMart data set into your data source."
	echo "Options:"
	echo "  --db <database>   Database driver to use:"
	echo "                     * oracle (default user 'SYSTEM');"
	echo "                     * db2 (default user 'db2inst1' with password 'db2inst1-pwd');"
	echo "                     * mysql;"
	echo "                     * postgres;"
	echo "                     * sqlserver;"
	echo "                     * sybase;"
	echo "                     * teradata;"
	echo "  --db-user <user>  Optional string to specify DB username."
	echo "  --db-pass <pass>  Optional string to specify DB password."
	echo "  --db-host <host>  Optional string to specify DB hostname."
	echo "                     [default: localhost]"
}

db=
db_host=localhost
db_user=
db_pass=
db_port=

while [ $# -gt 0 ]; do
	case "$1" in
		(--help) usage; exit 0;;
		(--db) shift; db="$1"; shift;;
		(--db-user) shift; db_user="$1"; shift;;
		(--db-pass) shift; db_pass="$1"; shift;;
		(--db-host) shift; db_host="$1"; shift;;
		(--db-port) shift; db_port="$1"; shift;;
		(*) error "Unknown argument '$1'"; exit 1;;
	esac
done

load_data()	{
	configure_db

	echo ":: extracting dataset..."
	unzip -q -n data/DataScript.zip -d data

	echo ":: compiling loader..."
	javac -cp "${class_path}" \
		src/MondrianFoodMartLoader.java

	echo ":: starting loader..."
	java -cp "${class_path}" \
		-Dlog4j.configuration=file:log4j.properties \
		MondrianFoodMartLoader \
		-verbose \
		-inputFile=data/FoodMartCreateData.sql \
		-jdbcDrivers=${db_driver} \
		-outputJdbcUser=${db_user} \
		-outputJdbcPassword=${db_pass} \
		-outputJdbcURL=${db_url} \
		-tables \
		-data \
		-indexes
}

cd $(dirname $0)

load_data

# vim: noet
