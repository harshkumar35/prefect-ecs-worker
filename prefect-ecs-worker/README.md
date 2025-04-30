# Prefect Worker on AWS ECS Fargate – Terraform Setup

This project deploys a Prefect worker as an ECS service on Fargate using Infrastructure as Code (Terraform).

---

## 🔧 Why Terraform?

Terraform was chosen because:
- It supports modular and reusable infrastructure patterns.
- It works across cloud providers.
- It has rich community support and tooling.

---

## 📦 Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform CLI installed (>= v1.2.0)
- Prefect Cloud account with API key
- AWS Secrets Manager with secret named `prefect-api-key`

---

## 🚀 Getting Started

1. Clone this repo:

```bash
git clone https://github.com/your/repo.git
cd prefect-ecs-worker