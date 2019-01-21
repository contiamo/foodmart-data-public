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
		(db2)
			export JDriver="-jdbcDrivers=com.ibm.db2.jcc.DB2Driver"
			#default DB2 credentials
			export DBCredentials="-outputJdbcUser=db2inst1 -outputJdbcPassword=db2inst1-pwd"
			export JURL="-outputJdbcURL=jdbc:db2://localhost:50000/foodmart"
			;;
		(mysql)
			export JDriver="-jdbcDrivers=com.mysql.jdbc.Driver"
			export JURL="-outputJdbcURL=jdbc:mysql://localhost/foodmart"
			;;
		(postgres)
			export JDriver="-jdbcDrivers=org.postgresql.Driver"
			export JURL="-outputJdbcURL=jdbc:postgresql://localhost/foodmart"
			;;
		(sqlserver)
			export JDriver="-jdbcDrivers=net.sourceforge.jtds.jdbc.Driver"
			export JURL="-outputJdbcURL=jdbc:jtds:sqlserver://localhost/foodmart"
			;;
		(sybase)
			export JDriver="-jdbcDrivers=net.sourceforge.jtds.jdbc.Driver"
			export JURL="-outputJdbcURL=jdbc:jtds:sybase://localhost/foodmart"
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
}

# Check which database is to be loaded.
db=
while [ $# -gt 0 ]; do
	case "$1" in
		(--help) usage; exit 0;;
		(--db) shift; db="$1"; shift;;
		(--db-pass) shift; db_pass="$1"; shift;;
		(*) error "Unknown argument '$1'"; exit 1;;
	esac
done

# Load the database.
loadData()	{
	configureDB
	java -cp "${MonClassPath}" \
	mondrian.test.loader.MondrianFoodMartLoader \
	-inputFile=./data/FoodMartCreateData.sql \
	${DBOptions} ${JDriver} ${JUser:-} ${JPass:-} ${JURL} ${DBCredentials}
}

cd $(dirname $0)
loadData
exit 0

# vim: noet
