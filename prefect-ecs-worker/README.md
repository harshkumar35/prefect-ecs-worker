
# Prefect Worker on AWS ECS Fargate – Terraform Setup

This project deploys a **Prefect worker** as an **ECS service** on **AWS Fargate** using **Terraform**. The worker connects to **Prefect Cloud** for workflow orchestration.

---

## 🔧 Why Terraform?

- Modular and reusable infrastructure code.
- Easy state management and dependency tracking.
- Works across multiple cloud providers (future-proof).

---

## 📦 Prerequisites

Before deploying, ensure you have the following:

1. **AWS CLI**:
   - Installed and configured (`aws configure`).
   - Valid credentials with permissions for ECS, IAM, VPC, and Secrets Manager.

2. **Terraform CLI**:
   - Installed (version >= 1.2.0). Download it from [here](https://developer.hashicorp.com/terraform/downloads).

3. **Prefect Cloud Account**:
   - Create an account at [Prefect Cloud](https://app.prefect.cloud/).
   - Obtain your **Account ID**, **Workspace ID**, and **API Key**.

4. **AWS Secrets Manager**:
   - Store your Prefect API key in AWS Secrets Manager with the name `prefect-api-key`.

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/harshkumar35/prefect-ecs-worker.git
cd prefect-ecs-worker
```

> Replace `yourusername` with your GitHub username or use the provided ZIP file.

### 2. Configure AWS Credentials

Run the following command and provide your AWS credentials:

```bash
aws configure
```

### 3. Store Prefect API Key in AWS Secrets Manager

If not already stored, run this command:

```bash
aws secretsmanager create-secret --name prefect-api-key --secret-string '{"PREFECT_API_KEY":"<YOUR_PREFECT_API_KEY>"}'
```

Replace `<YOUR_PREFECT_API_KEY>` with your actual Prefect API key.

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Apply the Terraform Configuration

Deploy the infrastructure:

```bash
terraform apply
```

When prompted, provide:
- `prefect_account_id`: Your Prefect Cloud Account ID.
- `prefect_workspace_id`: Your Prefect Cloud Workspace ID.

Example:

```plaintext
var.prefect_account_id
Enter a value: cd827ec3-766d-45cd-9bee-ee3542e30cb4

var.prefect_workspace_id
Enter a value: 826f8cc8-726f-4fcc-ab25-ea3a1f655e2b
```

Review the plan and confirm by typing `yes`.

---

## ✅ Verification Steps

After deployment, verify the setup:

1. **AWS Console**:
   - Go to the [ECS Dashboard](https://console.aws.amazon.com/ecs/home):
     - Confirm that the cluster `prefect-cluster` exists.
     - Check if the service `dev-worker` is running.

2. **Prefect Cloud**:
   - Go to your workspace in [Prefect Cloud](https://app.prefect.cloud/).
   - Confirm that the work pool `ecs-work-pool` has one active agent (`dev-worker`).

---

## 🧹 Cleanup

To avoid unnecessary charges, destroy the infrastructure:

```bash
terraform destroy
```

---

## 🔗 Useful Links

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Prefect Documentation](https://docs.prefect.io/)
- [AWS ECS Fargate Documentation](https://docs.aws.amazon.com/AmazonECS/latest/userguide/using_awsVPC.html)
