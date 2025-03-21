# GCP providers
provider "google" {
    credentials = file(var.gcp_svc_key)
    project     = var.gcp_project_id
    region      = var.gcp_region
}

provider "google-beta" {
    credentials = file(var.gcp_svc_key)
    project     = var.gcp_project_id
    region      = var.gcp_region
}