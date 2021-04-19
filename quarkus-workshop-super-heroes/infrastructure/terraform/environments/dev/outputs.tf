# Outputs like DB connection strings that can be used by the services.
# Do not add secrets as outputs! They are stored in GCP Secrets Manager in secrets.tf

output "omnibus" {
    value = module.omnibus
}
