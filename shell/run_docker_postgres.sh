docker run --name postgres -e POSTGRES_DB=vapor_database \
    -e POSTGRES_USER=vapor_username \
    -e POSTGRES_PASSWORD=vapor_password \
    -p 5434:5432 -d postgres
