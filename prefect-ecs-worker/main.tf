# -----------------------------
# VPC Setup using AWS Module
# -----------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.tags.Name
  cidr = var.vpc_cidr

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  reuse_nat_ips        = true
  map_public_ip_on_launch = true
  enable_dns_hostnames = true

  tags = var.tags
}

# -----------------------------
# IAM Role for ECS Task Execution
# -----------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "prefect-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "secrets_manager_access" {
  name = "prefect-secrets-access"
  role = aws_iam_role.ecs_task_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = data.aws_secretsmanager_secret.prefect_api_key.arn
    }]
  })
}

# -----------------------------
# Fetch Prefect API Key from Secrets Manager
# -----------------------------
data "aws_secretsmanager_secret" "prefect_api_key" {
  name = var.prefect_api_secret_name
}

# -----------------------------
# ECS Cluster
# -----------------------------
resource "aws_ecs_cluster" "prefect_cluster" {
  name = "prefect-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}

# -----------------------------
# Security Group for ECS Tasks
# -----------------------------
resource "aws_security_group" "ecs_tasks" {
  name        = "prefect-ecs-worker-sg"
  description = "Allow only outbound traffic for Prefect worker"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    self        = true
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# -----------------------------
# ECS Task Definition
# -----------------------------
resource "aws_ecs_task_definition" "prefect_worker_task" {
  family                   = "prefect-worker-task"
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "prefect-worker"
    image     = "prefecthq/prefect:2-latest"
    essential = true
    environment = [
      {
        name  = "PREFECT_API_URL"
        value = "https://api.prefect.cloud/api/accounts/${var.prefect_account_id}/workspaces/${var.prefect_workspace_id}"
      },
      {
        name  = "PREFECT_WORK_POOL_NAME"
        value = "ecs-work-pool"
      }
    ]
    secrets = [{
      name      = "PREFECT_API_KEY"
      valueFrom = data.aws_secretsmanager_secret.prefect_api_key.arn
    }]
    log_configuration = {
      log_driver = "awslogs"
      options = {
        awslogs-group         = "/ecs/prefect-worker"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

# -----------------------------
# ECS Service
# -----------------------------
resource "aws_ecs_service" "prefect_worker_service" {
  name            = "dev-worker"
  cluster         = aws_ecs_cluster.prefect_cluster.id
  task_definition = aws_ecs_task_definition.prefect_worker_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets         = module.vpc.private_subnets
  }

  tags = var.tags
}