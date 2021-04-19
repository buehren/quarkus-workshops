variable "environment" {
    description = "This is the environment where your webapp is deployed, e.g. dev or prod"
}

variable "services" {
    description = "The microservices running in the environment created by this Terraform configuration. Lower-case alphanumeric characters only, singular."
    type = list(string)
}

variable "gcp_project_id" {
    description = "The Google Cloud Platform project in which your webapp will be deployed. Create separate projects for DEV, QA, PROD etc."
}

variable "gcp_region" {
    description = "The Google Cloud Platform region where your webapp will be deployed."
}

variable "gcp_sqldb_instance_ipv4_enabled" {
    description = "Assign a public IP address to the GCP database instance? (if no external networks are authorized, Cloud SQL Proxy is required)"
    type = bool
    default = true
}

variable "gcp_sqldb_instance_activation_policy" {
    description = "Start (ALWAYS) or stop (NEVER) the GCP database instance. (Before stopping, set gcp_sqldb_instance_ipv4_enabled to false to avoid paying for unused IP address.)"
    type = string
    default = "ALWAYS"
}

variable "gcp_vpc_connector_enabled" {
    description = "Start or stop the GCP VPC connector for Serverless VPC Access"
    type = bool
    default = true
}


variable "mongodbatlas_project_id" {
    description = "This is the MongoDB Atlas project (hexadecimal ID) in which your webapp will be deployed. Create separate projects for DEV, QA, PROD etc."
}

variable "mongodbatlas_region" {
    description = "This is the MongoDB Atlas region where your webapp will be deployed."
}

variable "mongodbatlas_ip_access_cidr_block" {
    description = "Grants access from IPs (CIDR) to the project's clusters (do not enable this for the production cluster or clusters with sensitive data)."
    default = ""
}
