docker stop postgres-test
docker rm postgres-test

docker run --name postgres-test \
    -e POSTGRES_DB=vapor-test \
    -e POSTGRES_USER=vapor_username \
    -e POSTGRES_PASSWORD=vapor_password \
    -p 5433:5432 -d postgres
