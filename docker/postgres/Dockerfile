FROM openjdk:8u171-jdk-stretch

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
#RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.6``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Install ``python-software-properties``, ``software-properties-common`` and PostgreSQL 9.6
#  There are some warnings (in red) that show up during the build. You can hide
#  them by prefixing each apt-get statement with DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --allow-unauthenticated software-properties-common postgresql-9.6 postgresql-client-9.6 postgresql-contrib-9.6

# Note: The official Debian and Ubuntu images automatically ``apt-get clean``
# after each ``apt-get``

# Copy the DB data
COPY FoodMartLoader.sh /FoodMartLoader.sh
COPY data /data
COPY drivers /drivers
COPY libs /libs
RUN chmod +x /FoodMartLoader.sh && chown postgres /FoodMartLoader.sh 

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
#RUN sed "s/host.*all.*all.*127.0.0.1\/32.*md5/host    all             all             0.0.0.0\/0            trust/g" -i /etc/postgresql/9.6/main/pg_hba.conf
RUN sed "s/md5/trust/g" -i /etc/postgresql/9.6/main/pg_hba.conf && echo "host    all             all             0.0.0.0/0            trust" >> /etc/postgresql/9.6/main/pg_hba.conf 
# And add ``listen_addresses`` to ``/etc/postgresql/9.6/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.6/main/postgresql.conf


# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.6`` package when it was ``apt-get installed``
USER postgres

RUN /etc/init.d/postgresql start &&\
    # unzip /etc/postgresql/DataScript.zip /etc/postgresql/ &&\
    echo "create database foodmart;" | psql -U postgres &&\
    psql --command "CREATE USER root WITH SUPERUSER PASSWORD 'test';" &&\
    psql --command "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO root;" &&\
    psql --command "CREATE USER foodmart WITH SUPERUSER PASSWORD 'test';" &&\
    psql --command "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO foodmart;" &&\
    echo "Running FoodMartLoader" &&\
    /FoodMartLoader.sh --db postgres

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Set the default command to run when starting the container
CMD /usr/lib/postgresql/9.6/bin/postgres -D /var/lib/postgresql/9.6/main -c config_file=/etc/postgresql/9.6/main/postgresql.conf
