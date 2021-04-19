# Google Cloud Platform (GCP)
# https://registry.terraform.io/providers/hashicorp/google/latest/docs

provider "google" {
    # Expecting environment variable when running locally:
    # GOOGLE_APPLICATION_CREDENTIALS=... (credentials file)

    project = var.gcp_project_id
    region  = var.gcp_region
    #zone    = var.gcp_zone
}

# Data of the GCP project, e.g. data.google_project.project.number

data "google_project" "project" {
}

# APIs

resource "google_project_service" "services" {
    for_each = toset(var.gcp_services)
    service = each.key
    disable_dependent_services = true
}

# Grant roles
#
# google_project_iam_member: Non-authoritative. Updates the IAM policy to grant a role to a new member.
# Other members for the role for the project are preserved.

# Grant roles to Cloud Build

resource "google_project_iam_member" "cloudbuild_editor" {
    # Required for running Terraform scripts managing Google Cloud resources
    role = "roles/editor"
    member = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}
resource "google_project_iam_member" "cloudbuild_secretAccessor" {
    # Required for running Terraform scripts that read secrets from Secret Manager
    role = "roles/secretmanager.secretAccessor"
    member = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}
resource "google_project_iam_member" "cloudbuild_runAdmin" {
    # Required to deploy new Cloud Run services or revisions
    role = "roles/run.admin"
    member = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}
resource "google_project_iam_member" "cloudbuild_serviceAccountUser" {
    # Required to deploy new Cloud Run services or revisions
    role = "roles/iam.serviceAccountUser"
    member = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

# Grant roles to Cloud Run (we could run the services with their own service accounts for more targeted access rights)

resource "google_project_iam_member" "cloudrun_secretAccessor" {
    # Required to deploy new Cloud Run services or revisions
    role = "roles/secretmanager.secretAccessor"
    member = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}


# VPC

resource "google_compute_network" "vpc" {
    name                    = "vpc-${var.environment}"
    routing_mode            = "GLOBAL"
    auto_create_subnetworks = true
}

# IP Addresses

resource "google_compute_global_address" "ip_addresses" {
    name = "ip-addresses-${var.environment}"
    address_type = "INTERNAL"
    purpose = "VPC_PEERING"
    prefix_length = 20
    network = google_compute_network.vpc.self_link
}

# VPC Peerings

# Required for Connection between Cloud Run and Cloud SQL
resource "google_service_networking_connection" "vpc_peering_servicenetworking" {
    network = google_compute_network.vpc.self_link
    service = "servicenetworking.googleapis.com"
    reserved_peering_ranges = [google_compute_global_address.ip_addresses.name]
}

# Required for Connection to MongoDB Atlas clusters
resource "google_compute_network_peering" "vpc_peering_mongodbatlas" {
    name = "peering-mongodbatlas"
    network = google_compute_network.vpc.self_link
    peer_network = "https://www.googleapis.com/compute/v1/projects/${mongodbatlas_network_peering.vpc_peering_google.atlas_gcp_project_id}/global/networks/${mongodbatlas_network_peering.vpc_peering_google.atlas_vpc_name}"
}

# Required for Connection to Apache Kafka in Confluent Cloud
//resource "google_compute_network_peering" "peering" {
//    name            = var.peer_name
//    network         = "projects/${var.customer_project}/global/networks/${var.customer_vpc}"
//    peer_network    = "projects/${var.confluent_project}/global/networks/${var.confluent_vpc}"
//}

# Serverless VPC Access

resource "google_vpc_access_connector" "serverless_vpc_connector" {
    count = var.gcp_vpc_connector_enabled ? 1 : 0
    name = "vpc-connector"
    ip_cidr_range = "10.2.0.0/28" # mask must be 28
    min_throughput = 200
    max_throughput = 300
    network = google_compute_network.vpc.name
}

# SQL Database Instance (one instance shared between all services)

# This setup does not provide high availability / read replicas.
# If that should be required, consider using an existing module:
# - https://registry.terraform.io/modules/GoogleCloudPlatform/sql-db/google/latest
#   https://github.com/GoogleCloudPlatform/terraform-google-sql-db
# - https://registry.terraform.io/modules/gruntwork-io/sql/google/latest
#   https://github.com/gruntwork-io/terraform-google-sql

resource "google_sql_database_instance" "sql_instance" {
    name   = "sql-instance-${var.environment}"
    settings {
        tier = "db-f1-micro"
        disk_type = "PD_SSD"
        disk_size = 10

        activation_policy = var.gcp_sqldb_instance_activation_policy # Start or stop the instance (before stopping, disable public IP address)

        ip_configuration {
            ipv4_enabled = var.gcp_sqldb_instance_ipv4_enabled # Public IP address: no external networks are authorized, Cloud SQL Proxy is required
            private_network = google_compute_network.vpc.self_link
        }
    }

    database_version = "POSTGRES_13"

    deletion_protection = true # Set to false before destroying
    lifecycle {
        prevent_destroy = true # Set to false before destroying
    }

    timeouts {
        create = "30m"
        update = "30m"
        delete = "30m"
    }

    depends_on = [google_service_networking_connection.vpc_peering_servicenetworking]
}

# SQL database super user (cloudsqlsuperuser)

resource "google_sql_user" "superuser" {
    name = "terraform"
    password = random_password.google_sql_superuser_password.result
    instance = google_sql_database_instance.sql_instance.name
}

resource "random_password" "google_sql_superuser_password" {
    length = 64
    special = true
}

//# SQL databases for all services
//# For service "foo":
//# DB name: foo_db
//
//resource "google_sql_database" "databases" {
//    count = length(var.services)
//    name = "${var.services[count.index]}_db"
//    instance = google_sql_database_instance.sql_instance.name
//}
//
//# SQL database users for all services
//# For service "foo":
//# username: foo-service
//
//resource "google_sql_user" "users" {
//    count = length(var.services)
//    name = "${var.services[count.index]}-service"
//    password = random_password.password.result
//    instance = google_sql_database_instance.sql_instance.name
//}
