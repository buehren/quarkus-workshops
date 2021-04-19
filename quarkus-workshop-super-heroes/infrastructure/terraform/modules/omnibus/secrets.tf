// Store credentials in Google Cloud Platform's Secret Manager.

// These credentials are used by the services.
//
// The credentials required by Terraform are added to Secret Manager by terraform-env.sh
// (they must be available in Secret Manager before Terraform runs in Google Cloud Build).



// MongoDB

resource "google_secret_manager_secret" "secret_mongodb_passwords" {
    for_each = toset(var.services)
    secret_id = "service-${each.key}_mongodb-password"

    replication {
        automatic = true
    }
}

resource "google_secret_manager_secret_version" "secretdata_mongodb_passwords" {
    for_each = toset(var.services)
    secret = google_secret_manager_secret.secret_mongodb_passwords[each.key].id
    secret_data = random_password.mongodb_passwords[each.key].result
}


// PostgreSQL

resource "google_secret_manager_secret" "secret_sqldb_passwords" {
    for_each = toset(var.services)
    secret_id = "service-${each.key}_sqldb-password"

    replication {
        automatic = true
    }
}

resource "google_secret_manager_secret_version" "secretdata_sqldb_passwords" {
    for_each = toset(var.services)
    secret = google_secret_manager_secret.secret_sqldb_passwords[each.key].id
    secret_data = random_password.postgresql_passwords[each.key].result
}



// Apache Kafka

resource "google_secret_manager_secret" "secret_kafka_apikey_secrets" {
    for_each = toset(var.services)
    secret_id = "service-${each.key}_kafka-apikey-secret"

    replication {
        automatic = true
    }
}

resource "google_secret_manager_secret_version" "secretdata_kafka_apikey_secrets" {
    for_each = toset(var.services)
    secret = google_secret_manager_secret.secret_kafka_apikey_secrets[each.key].id
    secret_data = confluentcloud_api_key.services_kafka_cluster_api_keys[each.key].secret
}
