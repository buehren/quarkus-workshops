environment="dev"
services = ["hero","villain","fight","statistics"]

gcp_project_id="my-microservices-playground-2"
gcp_region="europe-west1" # Belgium, because MongoDB Free/Shared Clusters are not available in Frankfurt (europe-west3)

mongodbatlas_project_id="6064ab28ffec62268a61ace2"
mongodbatlas_region="WESTERN_EUROPE" # Belgium, because MongoDB Free/Shared Clusters are not available in Frankfurt (EUROPE_WEST_3)
#mongodbatlas_ip_access_cidr_block="0.0.0.0/0" # do not enable this for the production cluster or clusters with sensitive data
