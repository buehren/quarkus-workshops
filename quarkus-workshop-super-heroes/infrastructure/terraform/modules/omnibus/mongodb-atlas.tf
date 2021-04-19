# MongoDB Atlas
# https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs

provider "mongodbatlas" {
    # Expecting environment variables:
    # MONGODB_ATLAS_PUBLIC_KEY
    # MONGODB_ATLAS_PRIVATE_KEY
}


# Peering with Google Cloud Platform (GCP) VPC

# Peering connections will only apply to dedicated-tier (M10 and above) clusters.

# Terraform currently does not delete or update this peering setting at MongoDB Atlas.
# Before updating this via terraform apply, remove it in the MongoDB Atlas GUI and delete this resource in Terraform:
# terraform state rm module.omnibus.mongodbatlas_network_peering.vpc_peering_google
resource "mongodbatlas_network_peering" "vpc_peering_google" {
    project_id = var.mongodbatlas_project_id
    atlas_cidr_block = "192.168.0.0/18"
    container_id = mongodbatlas_cluster.cluster.container_id
    provider_name  = "GCP"
    gcp_project_id = var.gcp_project_id
    network_name   = google_compute_network.vpc.name
}


# Enable IP access to the project's clusters,

# use 0.0.0.0/0 for access from anywhere (do not enable this for the production cluster or clusters with sensitive data).
resource "mongodbatlas_project_ip_access_list" "ip_access_external" {
    count = var.mongodbatlas_ip_access_cidr_block!="" ? 1 : 0
    project_id = var.mongodbatlas_project_id
    cidr_block = var.mongodbatlas_ip_access_cidr_block
}

resource "mongodbatlas_project_ip_access_list" "ip_access_google_automode_vpc" {
    project_id = var.mongodbatlas_project_id
    # GCP networks generated in auto-mode use a CIDR range of 10.128.0.0/9
    # https://cloud.google.com/vpc/docs/vpc#subnet-ranges
    cidr_block = "10.128.0.0/9"
}

resource "mongodbatlas_project_ip_access_list" "ip_access_google_serverless_vpc_connector" {
    project_id = var.mongodbatlas_project_id
    # GCP networks generated in auto-mode use a CIDR range of 10.128.0.0/9
    # https://cloud.google.com/vpc/docs/vpc#subnet-ranges
    cidr_block = google_vpc_access_connector.serverless_vpc_connector[0].ip_cidr_range
}


# MongoDB Atlas Cluster (one cluster shared between all services)

resource "mongodbatlas_cluster" "cluster" {
    project_id = var.mongodbatlas_project_id
    name = "mongodb-cluster-${var.environment}"
    auto_scaling_disk_gb_enabled = false

    //Provider Settings
    provider_name  = "GCP"
    provider_instance_size_name = "M10"
    provider_region_name = var.mongodbatlas_region

//    provider_name  = "TENANT"
//    backing_provider_name = "GCP"
//    provider_instance_size_name = "M2"
//    provider_region_name = var.mongodbatlas_region

    # https://feedback.mongodb.com/forums/924145-atlas/suggestions/39458053-allow-atlas-clusters-to-be-paused-using-terraform
    # https://github.com/mongodb/terraform-provider-mongodbatlas/issues/105
    #paused = var.mongodbatlas_cluster_paused

    lifecycle {
        #prevent_destroy = true # Set to false before destroying
    }

    #depends_on = [google_compute_network_peering.vpc_peering_mongodbatlas]
}


# MongoDB users for all services (separate DB for each service, DBs are created when used).
# For service "foo":
# DB name: fooDB
# username: foo-service

resource "mongodbatlas_database_user" "users" {
    for_each = toset(var.services)
    username = "service-${each.key}"
    password = random_password.mongodb_passwords[each.key].result
    project_id = var.mongodbatlas_project_id
    auth_database_name  = "admin"

    roles {
        role_name = "readWrite"
        database_name = "${each.key}DB"
    }
}

resource "random_password" "mongodb_passwords" {
    for_each = toset(var.services)
    length = 32
    special = true
}
