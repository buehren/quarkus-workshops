// Confluent Cloud + Apache Kafka Terraform providers
// https://github.com/Mongey/terraform-provider-confluentcloud (see ccloud/ for attributes of the resources)
// https://github.com/Mongey/terraform-provider-kafka (see kafka/ for attributes of the resources)

// Not used yet: Confluent Platform Tools (i.e. Schema Registry, REST Proxy, Kafka Connect, KSQL, Control Center)
// https://docs.confluent.io/cloud/current/client-apps/tools.html
// https://github.com/confluentinc/ccloud-tools/tree/master/terraform


provider "confluentcloud" {
    // Set these environment variables:
    //   CONFLUENT_CLOUD_USERNAME (e-mail address for logging in at http://confluent.cloud)
    //   CONFLUENT_CLOUD_PASSWORD
    // The login e-mail address gives Terraform access to the whole Confluent Cloud account!
    // Create separate Confluent Cloud Accounts with separate login e-mail addresses for DEV, QA, PROD environments
    // to grant Terraform only access to one or some of them (there is no ACL to grant access to environments yet).
    //
    // An API Key ID and Secret CANNOT be used here (maybe later?).
}

locals {
    confluentcloud_environment_name = var.gcp_project_id
}

// Create environment in Confluent Cloud

resource "confluentcloud_environment" "environment" {
  name = local.confluentcloud_environment_name
}

// Create API Keys in Confluent Cloud for accessing the Kafka Cluster

// API Key to use in Terraform with full access to the cluster
resource "confluentcloud_api_key" "terraform_kafka_cluster_api_key" {
    cluster_id = confluentcloud_kafka_cluster.cluster.id
    environment_id = confluentcloud_environment.environment.id
    description = "API Key of Terraform for full access to the Kafka Cluster ${confluentcloud_kafka_cluster.cluster.name} in ${local.confluentcloud_environment_name}"
}

// API Keys to use in the services with access to the cluster controlled by ACLs of the corresponding service accounts
resource "confluentcloud_api_key" "services_kafka_cluster_api_keys" {
    for_each = toset(var.services)
    user_id = confluentcloud_service_account.service_accounts[each.key].id
    cluster_id = confluentcloud_kafka_cluster.cluster.id
    environment_id = confluentcloud_environment.environment.id
    description = "API Key of service ${each.key} for ACL access to the Kafka Cluster ${confluentcloud_kafka_cluster.cluster.name} in ${local.confluentcloud_environment_name}"
}

// Create Service Accounts in Confluent Cloud

resource "confluentcloud_service_account" "service_accounts" {
    for_each = toset(var.services)
    name = "service-${each.key}_${local.confluentcloud_environment_name}"
    description = "Account of service ${each.key} in ${local.confluentcloud_environment_name}"
}

// Create Kafka Cluster in Confluent Cloud

resource "confluentcloud_kafka_cluster" "cluster" {
  name  = "kafka-cluster-${var.environment}"
  service_provider = "gcp"
  region = var.gcp_region
  availability = "LOW"
  environment_id  = confluentcloud_environment.environment.id
  deployment = {
    sku = "BASIC"
  }
  network_egress = 100
  network_ingress = 100
  storage = 5000
}


// Configure Provider for accessing the Kafka Cluster

locals {
    bootstrap_servers = [replace(confluentcloud_kafka_cluster.cluster.bootstrap_servers, "SASL_SSL://", "")]
}

provider "kafka" {
    bootstrap_servers = local.bootstrap_servers

    tls_enabled = true
    sasl_username = confluentcloud_api_key.terraform_kafka_cluster_api_key.key
    sasl_password = confluentcloud_api_key.terraform_kafka_cluster_api_key.secret
    sasl_mechanism = "plain"
    timeout = 10
}

// Create topics in the Kafka Cluster

locals {
    // https://www.terraform.io/docs/language/functions/defaults.html
    kafka_topics = defaults(var.kafka_topics, {
        replication_factor = 3
        partitions = 1
        retention_ms = 604800000 // 7 days
        cleanup_policy = "delete"
    })
}

resource "kafka_topic" "topics" {
    for_each = local.kafka_topics
    name = each.key // https://cnr.sh/essays/how-paint-bike-shed-kafka-topic-naming-conventions

    // number of replicas
    replication_factor = each.value.replication_factor

    // scaling: as many consumers as partitions for a topic, first 10 partitions in BASIC cluster are free
    partitions = each.value.partitions

    config = {
        // https://docs.confluent.io/platform/current/installation/configuration/topic-configs.html

        // Maximum time we will retain a log before we will discard old log segments to free up space if we are using
        // the "delete" retention policy. This represents an SLA on how soon consumers must read their data.
        // If set to -1, no time limit is applied.
        "retention.ms" = each.value.retention_ms

        // The default policy ("delete") will discard old segments when their retention time or size limit has been reached.
        // The "compact" setting will enable log compaction on the topic, i.e. retain at least the last known value
        // for each message key within the log of data for a single topic partition.
        "cleanup.policy" = each.value.cleanup_policy
    }
}

//resource "kafka_acl" "test" {
//    resource_name       = "syslog"
//    resource_type       = "Topic"
//    acl_principal       = "User:Alice"
//    acl_host            = "*"
//    acl_operation       = "Write"
//    acl_permission_type = "Deny"
//}
