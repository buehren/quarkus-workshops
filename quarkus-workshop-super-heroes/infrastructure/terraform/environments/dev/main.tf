terraform {
    backend "gcs" {
        bucket  = "my-microservices-playground-2_dev_terraform"
        prefix  = "dev/terraform/state"
    }
}

module "omnibus" {
    source = "../../modules/omnibus"

    environment=var.environment
    services=var.services

    gcp_project_id=var.gcp_project_id
    gcp_region=var.gcp_region
    gcp_vpc_connector_enabled=var.gcp_vpc_connector_enabled
    gcp_sqldb_instance_ipv4_enabled=var.gcp_sqldb_instance_ipv4_enabled
    gcp_sqldb_instance_activation_policy=var.gcp_sqldb_instance_activation_policy

    mongodbatlas_project_id=var.mongodbatlas_project_id
    mongodbatlas_region=var.mongodbatlas_region
    mongodbatlas_ip_access_cidr_block=var.mongodbatlas_ip_access_cidr_block # do not enable this for the production cluster or clusters with sensitive data
}
