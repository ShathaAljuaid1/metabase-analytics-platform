# Internal Analytics and Reporting Platform

A cloud-based internal analytics and reporting platform built with **Metabase** and deployed on **Microsoft Azure**.

The project uses **Terraform** for infrastructure provisioning, **Docker Compose** for container orchestration, **PostgreSQL** for data storage, and **Azure Key Vault with Managed Identity** for secure database credential management.

## Project Architecture

```text
                    Microsoft Azure
                         |
                  Azure Virtual Machine
                         |
                  Managed Identity
                         |
                  Azure Key Vault
                  (DB Credentials)
                         |
                  Docker Compose
             ____________|____________
            |            |            |
         Metabase    Metabase DB   Analytics DB
                         |              |
                    PostgreSQL      PostgreSQL
                                        |
                                 Superstore Data
```

## Technologies Used

- Microsoft Azure
- Terraform
- Docker & Docker Compose
- Metabase
- PostgreSQL
- Azure Key Vault
- Azure Managed Identity
- Bash
- Git & GitHub

## Infrastructure

Terraform provisions the Azure infrastructure required to host the platform, including:

- Resource Group
- Virtual Network
- Subnet
- Network Security Group
- Public IP
- Network Interface
- Ubuntu Linux Virtual Machine
- System-Assigned Managed Identity
- Azure Key Vault
- Key Vault RBAC Role Assignment

## Docker Services

The platform uses Docker Compose to run three main services:

### Metabase

Provides the web-based analytics and reporting interface.

### Metabase Database

A PostgreSQL database used by Metabase to store its internal configuration, users, questions, and dashboard information.

### Analytics Database

A separate PostgreSQL database containing the business dataset used for reporting and analysis.

The sample dataset contains:

- Orders
- Returns
- People

## Security

Database passwords are not stored in the GitHub repository.

Sensitive credentials are stored in **Azure Key Vault**.

The Azure VM uses a **System-Assigned Managed Identity** and the **Key Vault Secrets User** RBAC role to securely retrieve the required database credentials.

The deployment script retrieves the secrets at runtime before starting the Docker services.

```text
VM
 |
Managed Identity
 |
Key Vault
 |
Database Secrets
 |
Docker Compose
```

Files containing local secrets and Terraform state are excluded from Git using `.gitignore`.

## Deployment

### 1. Provision Azure Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2. Connect to the VM

```bash
ssh azureuser@<VM_PUBLIC_IP>
```

### 3. Install Docker

Run the setup script:

```bash
chmod +x setup.sh
./setup.sh
```

### 4. Deploy the Platform

The deployment script authenticates using the VM Managed Identity, retrieves database passwords from Azure Key Vault, and starts the containers.

```bash
chmod +x deploy.sh
./deploy.sh
```

### 5. Access Metabase

Open:

```text
http://<VM_PUBLIC_IP>:3000
```

## Dashboard

The project includes a **Superstore Sales Analytics Dashboard** built in Metabase.

The dashboard includes:

- Total Sales
- Total Profit
- Total Orders
- Profit Margin
- Sales by Region
- Sales by Category
- Monthly Sales Trend
- Profit by Category
- Top 10 Products by Sales
- Region Filter

## Repository Structure

```text
metabase-project/
|
|-- docker/
|   |-- data/
|   |-- init/
|   |-- .env.example
|   |-- deploy.sh
|   `-- docker-compose.yml
|
|-- scripts/
|   `-- setup.sh
|
|-- terraform/
|   |-- main.tf
|   |-- outputs.tf
|   `-- .terraform.lock.hcl
|
|-- .gitignore
`-- README.md
```

## Key Features

- Infrastructure as Code with Terraform
- Containerized deployment with Docker Compose
- Persistent PostgreSQL databases
- Interactive Metabase dashboards
- Azure Key Vault secret management
- Passwordless Azure authentication using Managed Identity
- RBAC-based access to secrets
- Automated Bash deployment
- Git-based source control

## Project Purpose

The purpose of this project is to demonstrate how an organization can deploy an internal analytics and reporting platform in Azure while applying cloud infrastructure automation, containerization, data visualization, and secure credential management.
