resource "aws_ecs_cluster" "web-cluster" {
  name = "${var.app_name}-${var.environment}"
  # capacity_providers = [aws_ecs_capacity_provider.capacity_provider.name]
  tags = {
    "env"       = "prod"
    "createdBy" = "hoaittt"
  }
}

resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "${var.app_name}-${var.environment}-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 85
    }
  }
}
data "template_file" "accounting" {
  template = file("container-definitions/container-def.json")
  vars = {
    app_image   = var.app_image
    nginx_image = var.nginx_image
    region      = var.aws_region
  }
}
# update file container-def, so it's pulling image from ecr
resource "aws_ecs_task_definition" "task-definition" {
  family                = "${var.app_name}-${var.environment}-family"
  container_definitions = data.template_file.accounting.rendered
  network_mode          = "bridge"
  volume {
    name = "webapp"
    # host_path = "/ecs/service-storage"
    host_path = null
  }
}
# resource "aws_ecs_task_definition" "task-definition-cron" {
#   family                = "prod-deviceme-web-family-cron"
#   container_definitions = file("container-definitions/container-def-cron.json")
#   network_mode          = "brige"
#   tags = {
#     "env"       = "prod"
#     "createdBy" = "hoaittt"
#   }
# }

resource "aws_ecs_service" "service" {
  name            = "${var.app_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.web-cluster.id
  task_definition = aws_ecs_task_definition.task-definition.arn
  desired_count   = 1
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    container_name   = "nginx"
    container_port   = 80
  }
  # Optional: Allow external changes without Terraform plan difference(for example ASG)
  lifecycle {
    ignore_changes = [desired_count]
  }
  force_new_deployment = true
  # deployment_minimum_healthy_percent = 0
  launch_type = "EC2"
  depends_on  = [aws_lb_listener.web-listener-https]
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/aws/ecs/${var.app_name}-${var.environment}"
  tags = {
    "env"       = "prod"
    "createdBy" = "hoaittt"
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 8
  min_capacity       = 1
  resource_id        = "service/clusterName/serviceName"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs-policy" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs-target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs-target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs-target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}
