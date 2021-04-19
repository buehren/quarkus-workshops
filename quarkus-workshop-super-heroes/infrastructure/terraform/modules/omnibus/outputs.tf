// Outputs like DB connection strings that can be used by the services.

// Do not add secrets as outputs! They are stored in GCP Secrets Manager in secrets.tf


// GCP

output "gcp_region" {
    value = var.gcp_region
}


// MongoDB

output "mongodb_connection_strings" {
    value = tomap({

        # Private IP addresses (e.g. for VPC peering)
        #   Private connection strings are not available w/ GCP until the reciprocal
        #   connection changes to available (i.e. when the status attribute changes
        #   to AVAILABLE on the 'mongodbatlas_network_peering' resource, which
        #   happens when the google_compute_network_peering and
        #   mongodbatlas_network_peering make a reciprocal connection).  Hence
        #   since the cluster can be created before this connection completes
        #   you may need to run `terraform refresh` to obtain the private connection strings.
        for service in var.services : service => mongodbatlas_cluster.cluster.connection_strings.0.private

        # Public IP addresses
        #for service in var.services : service => mongodbatlas_cluster.cluster.connection_strings.0.standard
    })
}


// PostgreSQL

output "sqldb_connection_names" {
    value = tomap({
        for service in var.services : service => google_sql_database_instance.sql_instance.connection_name
    })
}

output "sqldb_private_ip_addresses" {
    value = tomap({
        for service in var.services : service => google_sql_database_instance.sql_instance.private_ip_address
    })
}

output "sqldb_public_ip_addresses" {
    value = tomap({
        for service in var.services : service => google_sql_database_instance.sql_instance.public_ip_address
    })
}


// Apache Kafka

output "kafka_bootstrap_servers" {
    value = local.bootstrap_servers
}

output "kafka_apikeys" {
    value = tomap({
        for service in var.services : service => confluentcloud_api_key.services_kafka_cluster_api_keys[service].key
    })
}
