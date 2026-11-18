data "aws_caller_identity" "current" {}

locals {
  https_enabled  = var.certificate_arn != null
  listener_ports = local.https_enabled ? [80, 443] : [80]
  log_prefix     = "alb"
}

# ------------------------------------------------------ Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${var.name}-alb-"
  description = "Trafico entrante al ALB"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = toset(local.listener_ports)

    content {
      description = "HTTP(S) hacia el ALB"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.ingress_cidrs
    }
  }

  egress {
    description = "Hacia los targets"
    from_port   = var.target_port
    to_port     = var.target_port
    protocol    = "tcp"
    cidr_blocks = var.egress_cidrs
  }

  tags = merge(var.tags, { Name = "${var.name}-alb-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------- Bucket de access logs
resource "aws_s3_bucket" "logs" {
  count = var.enable_access_logs ? 1 : 0

  bucket        = "${var.name}-alb-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = var.access_logs_force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  count = var.enable_access_logs ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  count = var.enable_access_logs ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Los access logs del ALB solo admiten cifrado SSE-S3
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  count = var.enable_access_logs ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  count = var.enable_access_logs ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  rule {
    id     = "expire-access-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = var.access_logs_retention_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Cuenta de ELB de la región (válido para regiones anteriores a agosto de 2022, como us-east-1).
# En regiones nuevas habría que usar el principal de servicio logdelivery.elasticloadbalancing.amazonaws.com.
data "aws_elb_service_account" "this" {
  count = var.enable_access_logs ? 1 : 0
}

data "aws_iam_policy_document" "logs" {
  count = var.enable_access_logs ? 1 : 0

  statement {
    sid       = "AllowELBLogDelivery"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logs[0].arn}/${local.log_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.this[0].arn]
    }
  }

  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.logs[0].arn,
      "${aws_s3_bucket.logs[0].arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  count = var.enable_access_logs ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id
  policy = data.aws_iam_policy_document.logs[0].json

  depends_on = [aws_s3_bucket_public_access_block.logs]
}

# ------------------------------------------------------------------ ALB
resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  idle_timeout               = var.idle_timeout
  drop_invalid_header_fields = true
  enable_deletion_protection = var.enable_deletion_protection

  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []

    content {
      bucket  = aws_s3_bucket.logs[0].id
      prefix  = local.log_prefix
      enabled = true
    }
  }

  tags = merge(var.tags, { Name = "${var.name}-alb" })

  # El ALB comprueba los permisos del bucket al crearse
  depends_on = [aws_s3_bucket_policy.logs]
}

resource "aws_lb_target_group" "this" {
  name                 = "${var.name}-tg"
  port                 = var.target_port
  protocol             = "HTTP"
  target_type          = "instance"
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    path                = var.health_check.path
    matcher             = var.health_check.matcher
    interval            = var.health_check.interval
    timeout             = var.health_check.timeout
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
  }

  tags = merge(var.tags, { Name = "${var.name}-tg" })
}

# --------------------------------------------------------------- Listeners
# Sin certificado: el 80 reenvía al target group.
# Con certificado: el 80 redirige a HTTPS y el 443 reenvía.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = local.https_enabled ? "redirect" : "forward"
    target_group_arn = local.https_enabled ? null : aws_lb_target_group.this.arn

    dynamic "redirect" {
      for_each = local.https_enabled ? [1] : []

      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
}

resource "aws_lb_listener" "https" {
  count = local.https_enabled ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
