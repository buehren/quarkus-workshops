# PostgreSQL
# https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs

provider "postgresql" {
    # Connect to Google Cloud SQL PostgreSQL instance.
    # Expecting environment variable when running locally:
    # GOOGLE_APPLICATION_CREDENTIALS=... (credentials file)
    scheme = "gcppostgres"
    host = google_sql_database_instance.sql_instance.connection_name

    sslmode = "require"
    connect_timeout = 15

    username = google_sql_user.superuser.name
    password = google_sql_user.superuser.password
    superuser = false
}

# PostgreSQL Databases for all services
# For service "foo":
# DB name: foo_db

resource "postgresql_database" "databases" {
    for_each = toset(var.services)
    name = "${each.key}_db"

    lifecycle {
        prevent_destroy = true # Set to false before destroying
    }
}

# PostgreSQL schemas for all services
# For service "foo":
# schema: foo (in database foo_db)

resource "postgresql_schema" "schemas" {
    for_each = toset(var.services)
    name = each.key
    database = postgresql_database.databases[each.key].name

    lifecycle {
        prevent_destroy = true # Set to false before destroying
    }
}

# PostgreSQL users for all services
# For service "foo":
# username: foo-service

resource "random_password" "postgresql_passwords" {
    for_each = toset(var.services)
    length = 32
    special = true
}

resource "postgresql_role" "roles" {
    for_each = toset(var.services)
    name = "service_${each.key}"
    password = random_password.postgresql_passwords[each.key].result
    search_path = [each.key] # default schema
    login = true
}

# Grant access to databases
# https://www.postgresql.org/docs/current/sql-grant.html

resource "postgresql_grant" "database_grants" {
    for_each = toset(var.services)
    database = postgresql_database.databases[each.key].name
    role = postgresql_role.roles[each.key].name
    object_type = "database"
    privileges  = ["CREATE", "CONNECT", "TEMPORARY"]
}

# Grant access to schemas
# https://www.postgresql.org/docs/current/sql-grant.html

resource "postgresql_grant" "schema_grants" {
    for_each = toset(var.services)
    database = postgresql_database.databases[each.key].name
    schema = postgresql_schema.schemas[each.key].name
    role = postgresql_role.roles[each.key].name
    object_type = "schema"
    privileges  = ["CREATE", "USAGE"]
}

# Revoke the default grant for every user to connect to any database

resource "postgresql_grant" "revoke_database_public" {
    for_each = toset(var.services)
    database = postgresql_database.databases[each.key].name
    role = "public"
    object_type = "database"
    privileges = []
}

# Revoke the default grant for every user to create a table in any public schema
// Does not work (yet):
// https://github.com/hashicorp/terraform-provider-postgresql/issues/165
// https://github.com/cyrilgdn/terraform-provider-postgresql/issues/33
//resource "postgresql_grant" "revoke_schema_public" {
//    for_each = toset(var.services)
//    database = postgresql_database.databases[each.key].name
//    role = "public"
//    schema = "public"
//    object_type = "schema"
//    privileges = []
//    with_grant_option = true
//}
