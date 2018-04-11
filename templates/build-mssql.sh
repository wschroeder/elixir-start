#!/bin/bash

set -x

password=$1
docker rm -f {{ELIXIR_PROJECT_NAME}}-mssql

set -e
docker run --network {{ELIXIR_PROJECT_NAME}}-uats --name {{ELIXIR_PROJECT_NAME}}-mssql -e 'ACCEPT_EULA=Y' -e "SA_PASSWORD=${password}" -d {{ELIXIR_PROJECT_NAME}}-mssql

while ! docker exec -i {{ELIXIR_PROJECT_NAME}}-mssql /opt/mssql-tools/bin/sqlcmd -b -S localhost -U sa -P ${password} -Q 'create database {{ELIXIR_PROJECT_NAME}}_dev'; do
    sleep 2s;
done

docker exec -i {{ELIXIR_PROJECT_NAME}}-mssql /opt/mssql-tools/bin/sqlcmd -b -S localhost -U sa -P ${password} -Q 'create database {{ELIXIR_PROJECT_NAME}}_test'
docker exec -i {{ELIXIR_PROJECT_NAME}}-mssql /opt/mssql-tools/bin/sqlcmd -b -S localhost -U sa -P ${password} -Q 'create database {{ELIXIR_PROJECT_NAME}}_prod'

