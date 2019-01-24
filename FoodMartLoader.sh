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

# Determine Java File Separator
case $(uname) in
	Linux|Darwin) JFSeparator=: ;;
	*) JFSeparator=\; ;;
esac

# Setup ClassPath for libraries & drivers
export MonClassPath="./libs/*${JFSeparator}./drivers/*"

# Error routine
error() {
	echo "Error: $1"
	exit 1
}

# Setup database specific variables.
configureDB()	{
	export DBOptions="-verbose -aggregates -tables -data -indexes"
	export DBCredentials="-outputJdbcUser=foodmart -outputJdbcPassword=foodmart"
	
	case $db in
		('') error "You must specify a database."; exit 1;;
		(oracle)
			if [[ ! "${db_pass:-}" ]]; then
				error "Please specify --db-pass for SYSTEM user."
			fi

			export JDriver="-jdbcDrivers=oracle.jdbc.driver.OracleDriver"
			export DBCredentials="-outputJdbcUser=SYSTEM -outputJdbcPassword=$db_pass"
			export JURL="-outputJdbcURL=jdbc:oracle:thin:@//${db_host}:1521/XEPDB1"
			;;
		(db2)
			export JDriver="-jdbcDrivers=com.ibm.db2.jcc.DB2Driver"
			#default DB2 credentials
			export DBCredentials="-outputJdbcUser=db2inst1 -outputJdbcPassword=${db_pass:-db2inst1-pwd}"
			export JURL="-outputJdbcURL=jdbc:db2://${db_host}:50000/foodmart"
			;;
		(mysql)
			export JDriver="-jdbcDrivers=com.mysql.jdbc.Driver"
			export JURL="-outputJdbcURL=jdbc:mysql://${db_host}/foodmart"
			;;
		(postgres)
			export JDriver="-jdbcDrivers=org.postgresql.Driver"
			export JURL="-outputJdbcURL=jdbc:postgresql://${db_host}/foodmart"
			;;
		(sqlserver)
			export JDriver="-jdbcDrivers=net.sourceforge.jtds.jdbc.Driver"
			export JURL="-outputJdbcURL=jdbc:jtds:sqlserver://${db_host}/foodmart"
			;;
		(sybase)
			export JDriver="-jdbcDrivers=net.sourceforge.jtds.jdbc.Driver"
			export JURL="-outputJdbcURL=jdbc:jtds:sybase://${db_host}/foodmart"
			;;
		(*) error "Unknown database selection."; exit 1;;
	esac
}

usage() {
	echo "$(basename $0) - import FoodMart data set into your data source."
	echo "Options:"
	echo "  --db <database>   Database driver to use:"
	echo "                     * oracle (user 'SYSTEM', password via --db-pass option);"
	echo "                     * db2 (user 'db2inst1', password 'db2inst1-pwd');"
	echo "                     * mysql;"
	echo "                     * postgres;"
	echo "                     * sqlserver;"
	echo "                     * sybase;"
	echo "  --db-pass <pass>  Optional string to specify DB password."
	echo "  --db-host <host>  Optional string to specify DB hostname."
	echo "                     [default: localhost]"
}

# Check which database is to be loaded.
db=
db_host=localhost
while [ $# -gt 0 ]; do
	case "$1" in
		(--help) usage; exit 0;;
		(--db) shift; db="$1"; shift;;
		(--db-pass) shift; db_pass="$1"; shift;;
		(--db-host) shift; db_host="$1"; shift;;
		(*) error "Unknown argument '$1'"; exit 1;;
	esac
done

# Load the database.
loadData()	{
	configureDB
	unzip -n data/DataScript.zip -d data
	java -cp "${MonClassPath}" \
	mondrian.test.loader.MondrianFoodMartLoader \
	-inputFile=./data/FoodMartCreateData.sql \
	${DBOptions} ${JDriver} ${JUser:-} ${JPass:-} ${JURL} ${DBCredentials}
}

cd $(dirname $0)
loadData
exit 0

# vim: noet
