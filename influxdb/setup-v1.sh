#!/bin/bash
set -e

echo "Adding DBRP mapping"
echo "BUCKET_ID = " ${DOCKER_INFLUXDB_INIT_BUCKET_ID}
echo "V1_DB_NAME = " ${V1_DB_NAME}

influx v1 dbrp create \
  --bucket-id ${DOCKER_INFLUXDB_INIT_BUCKET_ID} \
  --db ${V1_DB_NAME} \
  --rp ${V1_RP_NAME} \
  --default \
  --org ${DOCKER_INFLUXDB_INIT_ORG}