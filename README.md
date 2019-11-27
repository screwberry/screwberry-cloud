# screwberry-cloud
This part of the Screwberry project deploys infrastructure for a data pipeline in Azure using Terraform. The architecture includes IoT Hub, a VM running Grafana on Docker, and MS SQL server.

## Use screwberry-cloud

Follow these steps to deploy the infrastructure.

### Prerequisites

* Azure subscription.
* You have Terraform installed.
* Set the following Azure connection environment variables: `TF_VAR_client_id`, `TF_VAR_client_secret`, `TF_VAR_subscription_id`, and `TF_VAR_tenant_id`.
* Set the following SQL server environment variables: `TF_VAR_SQL_user`, and `TF_VAR_SQL_password`.
* You have az cli with the IoT extension installed (`az extension add --name azure-cli-iot-ext`).

### Install

1. Clone the repo.
2. In the folder, run `terraform apply` to deploy the infrastructure.
3. Run `device.bat` to register your edge device in IoT Hub and get its connection string. You'll need this in the screwberry-edge part of the project.
4. Get the endpoint string (TBA). You'll need this in the screwberry-3d part of the project.
5. Set up Grafana (TBA). https://grafana.com/docs/features/datasources/mssql/

### Configure (optional)

TBA: This section will be added later.

### Run

TBA: This section will be added later.
