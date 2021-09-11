resource "aws_ecs_cluster" "main" {
  name = var.service_name
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.service_name
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      "name" : "${var.service_name}",
      "image" : "nginx:latest",
      "essential" : true,
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-region" : "ap-northeast-1",
          "awslogs-stream-prefix" : "nginx",
          "awslogs-group" : "/ecs/${var.service_name}"
        }
      },
      "portMappings" : [
        {
          "protocol" : "tcp",
          "containerPort" : 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "main" {
  name             = var.service_name
  cluster          = aws_ecs_cluster.main.arn
  task_definition  = aws_ecs_task_definition.main.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.main.id]

    subnets = var.public_subnet_ids
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_cloudwatch_log_group" "for_ecs" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = 180
}
