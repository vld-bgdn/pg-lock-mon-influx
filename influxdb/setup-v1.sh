#!/bin/bash
set -e

#echo "Adding DBRP mapping"
#echo "BUCKET_ID = " ${DOCKER_INFLUXDB_INIT_BUCKET_ID}
#echo "DB_NAME = " ${DB_NAME}

influx v1 dbrp create \
  --bucket-id ${DOCKER_INFLUXDB_INIT_BUCKET_ID} \
  --db ${DB_NAME} \
  --rp ${RP_NAME} \
  --default \
  --org ${DOCKER_INFLUXDB_INIT_ORG}