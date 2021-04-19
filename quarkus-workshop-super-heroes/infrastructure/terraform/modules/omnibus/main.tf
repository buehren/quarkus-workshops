# TODO: Remote State
# https://cloud.google.com/solutions/managing-infrastructure-as-code?hl=de#configuring_terraform_to_store_state_in_a_cloud_storage_bucket
# https://www.terraform.io/docs/language/state/remote.html
# https://www.terraform.io/docs/language/state/sensitive-data.html

terraform {
    required_providers {
        mongodbatlas = {
            source = "mongodb/mongodbatlas"
        }
        postgresql = {
            source = "cyrilgdn/postgresql"
        }
        confluentcloud = {
            source = "Mongey/confluentcloud"
        }
        kafka = {
            source  = "Mongey/kafka"
            version = "0.2.11" // avoids error in later version - retry without version some day (and terraform init -upgrade)
        }
    }
    experiments = [module_variable_optional_attrs]
}
