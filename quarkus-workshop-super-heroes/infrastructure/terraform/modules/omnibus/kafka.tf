// Configure the Kafka Cluster

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
