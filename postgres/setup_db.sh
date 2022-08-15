#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER telegraf WITH PASSWORD '$TELEGRAF_PASSWORD';
    CREATE USER app WITH PASSWORD '$APP_PASSWORD';
	CREATE DATABASE testlockdb;
	GRANT ALL PRIVILEGES ON DATABASE testlockdb TO app;
    GRANT SELECT ON pg_stat_database TO telegraf;
    GRANT SELECT ON pg_stat_bgwriter TO telegraf;
    GRANT SELECT ON pg_locks TO telegraf;
    GRANT SELECT ON pg_stat_activity TO telegraf;
    GRANT pg_read_all_stats TO telegraf;

    \c testlockdb;
    CREATE TABLE users
    (
        id SERIAL,
        nickname text,
        balance numeric,
        CONSTRAINT "primary" PRIMARY KEY (id)
    )
    WITH (OIDS=FALSE);
    GRANT SELECT, INSERT, UPDATE, DELETE ON users TO app;
    INSERT INTO users (id, nickname, balance) VALUES (2, 'Beta', 160.0);
    INSERT INTO users (id, nickname, balance) VALUES (1, 'Alpha', 260.0);
    INSERT INTO users (id, nickname, balance) VALUES (3, 'Gamma', 510.50);
EOSQL