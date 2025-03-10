# Terraform commands to update and push changes
#init          Prepare your working directory for other commands
#validate      Check whether the configuration is valid
#plan          Show changes required by the current configuration
#apply         Create or update infrastructure
#destroy       Destroy previously-created infrastructure

# https://registry.terraform.io/modules/edosrecki/dataflow-pubsub-to-bigquery/google/latest/submodules/pubsub-to-bigquery
module "pubsub-to-bigquery" {
  source = "edosrecki/dataflow-pubsub-to-bigquery/google//modules/pubsub-to-bigquery"

  project  = var.gcp_project_id
  location = "US"
  region = var.gcp_region
  labels = {
    environment = "dev"
#     source      = "terraform"
  }

  service_account_name = "your-service-account-name"
  create_service_account = false
  bucket_name          = "${var.gcp_project_id}-user_data_bucket"
  topic_name           = "user-data"
  subscription_name    = "user-input-subscription"
  dataset_name         = "user_data"
  table_name           = "user_data_raw"
  errors_dataset_name  = "user_data_error"
  errors_table_name    = "user_data_error_tb"
  job_name             = "user-data-ingest-job"

  jobs = toset([
    {
      version    = "1",
      path       = "gs://dataflow-templates/latest/PubSub_Subscription_to_BigQuery"
      parameters = {}
    }
  ])

  topic_schema = {
    type     = "AVRO"
    encoding = "JSON"
    definition = jsonencode({
      name = "User"
      type = "record"
      fields = [
        {
            name = "first_name"
            type = "string"
        },
        {
            name: "last_name",
            type: "string",
        },
        {
            name: "gender",
            type: "string",
        },
        {
            name: "age",
            type: "int",
        },
        {
            name: "address",
            type: "string",
        }
      ]
    })
  }

table_schema = jsonencode([
        {
            "name": "first_name",
            "type": "STRING",
            "mode": "NULLABLE",
            "description": "user first name"
        },
        {
            "name": "last_name",
            "type": "STRING",
            "mode": "NULLABLE",
            "description": "user last name"
        },
        {
            "name": "gender",
            "type": "STRING",
            "mode": "NULLABLE",
            "description": "user gender"
        },
        {
            "name": "age",
            "type": "INTEGER",
            "mode": "NULLABLE",
            "description": "user age"
        },
        {
            "name": "address",
            "type": "STRING",
            "mode": "NULLABLE",
            "description": "user address"
        }
    ])
}