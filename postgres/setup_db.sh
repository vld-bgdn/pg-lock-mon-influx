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

    CREATE VIEW blocking_process AS
    SELECT blocked_locks.pid           AS blocked_pid,
             blocked_activity.usename  AS blocked_user,
             blocking_locks.pid        AS blocking_pid,
             blocking_activity.usename AS blocking_user,
             blocked_activity.query    AS blocked_statement,
             blocking_activity.query   AS blocking_statement
       FROM  pg_catalog.pg_locks         blocked_locks
        JOIN pg_catalog.pg_stat_activity blocked_activity  ON blocked_activity.pid = blocked_locks.pid
        JOIN pg_catalog.pg_locks         blocking_locks 
            ON blocking_locks.locktype = blocked_locks.locktype
            AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE
            AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
            AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
            AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
            AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
            AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
            AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
            AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
            AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
            AND blocking_locks.pid != blocked_locks.pid
        JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
        WHERE NOT blocked_locks.granted;

    GRANT SELECT on blocking_process TO telegraf;
    
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