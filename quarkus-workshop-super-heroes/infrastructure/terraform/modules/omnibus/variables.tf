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

variable "gcp_services" {
    description = "The Services/APIs to be enabled"
    type = list(string)
    default = [
        "cloudresourcemanager.googleapis.com",
        "compute.googleapis.com",
        "run.googleapis.com",
        "servicenetworking.googleapis.com",
        "vpcaccess.googleapis.com",
        "sqladmin.googleapis.com",
        "cloudbuild.googleapis.com",
    ]
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


variable "kafka_topics" {
    description = "Apache Kafka topics"
    type = map(
        // key = name of topic
        // https://cnr.sh/essays/how-paint-bike-shed-kafka-topic-naming-conventions
        object({
            // https://docs.confluent.io/platform/current/installation/configuration/topic-configs.html
            replication_factor = optional(number) # number of replicas
            partitions = optional(number) # scaling: as many consumers as partitions for a topic, first 10 partitions in BASIC cluster are free
            retention_ms = optional(number) # Maximum time we will retain a log before we will discard old log segments
            cleanup_policy = optional(string) # "delete": discard old segments, "compact": retain at least the last known value for each message key
        })
    )
    default = {
        "fights" = {
            partitions = 3
            retention_ms = 2592000000 // 30 days
        },
/*
        "product.product_data" = {
            partitions = 1
            cleanup_policy = "compact"
        },
        "product.production_data" = {
            partitions = 1
            cleanup_policy = "compact"
        },
        "inventory.product" = {
            partitions = 1
            cleanup_policy = "compact"
            retention_ms = 2592000000 // 30 days
        },
        "inventory.item" = {
            partitions = 1
            cleanup_policy = "compact"
            retention_ms = 2592000000 // 30 days
        },
        "storage.storage_unit" = {
            partitions = 1
            cleanup_policy = "compact"
        },
        "storage.sensor_values" = {
            partitions = 1
            cleanup_policy = "compact"
            retention_ms = 2592000000 // 30 days
        },
        "customer.customer_details" = {
            partitions = 1
            cleanup_policy = "compact"
            retention_ms = 62208000000 // 720 days = 24 * 30 days
        },
*/
    }
}

