data "archive_file" "event_processor" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda/event-processor/handler.py"
  output_path = "${path.module}/event-processor.zip"
}

data "archive_file" "event_query_api" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda/event-query-api/handler.py"
  output_path = "${path.module}/event-query-api.zip"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_cloudwatch_log_group" "event_processor" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-event-processor"
  retention_in_days = 14

  tags = {
    Repository = "retail-microservices-eks-platform"
  }
}

resource "aws_cloudwatch_log_group" "event_query_api" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-event-query-api"
  retention_in_days = 14

  tags = {
    Repository = "retail-microservices-eks-platform"
  }
}

resource "aws_iam_role" "event_processor" {
  name               = "${var.project_name}-${var.environment}-event-processor-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    Repository = "retail-microservices-eks-platform"
  }
}

resource "aws_iam_role_policy" "event_processor" {
  name = "${var.project_name}-${var.environment}-event-processor-policy"
  role = aws_iam_role.event_processor.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "WriteProcessorLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.event_processor.arn}:*"
      },
      {
        Sid    = "ReceiveMonitoringEvents"
        Effect = "Allow"
        Action = [
          "sqs:ChangeMessageVisibility",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ReceiveMessage"
        ]
        Resource = var.events_queue_arn
      },
      {
        Sid      = "WriteMonitoringEvents"
        Effect   = "Allow"
        Action   = "dynamodb:PutItem"
        Resource = var.events_table_arn
      },
      {
        Sid      = "ArchiveRawEvents"
        Effect   = "Allow"
        Action   = "s3:PutObject"
        Resource = "${var.event_archive_bucket_arn}/*"
      },
      {
        Sid      = "PublishCriticalEvents"
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = var.critical_events_topic_arn
      }
    ]
  })
}

resource "aws_lambda_function" "event_processor" {
  function_name = "${var.project_name}-${var.environment}-event-processor"
  role          = aws_iam_role.event_processor.arn
  handler       = "handler.handler"
  runtime       = "python3.12"
  timeout       = 30
  memory_size   = 256

  filename         = data.archive_file.event_processor.output_path
  source_code_hash = data.archive_file.event_processor.output_base64sha256

  environment {
    variables = {
      EVENTS_TABLE_NAME         = var.events_table_name
      EVENT_ARCHIVE_BUCKET      = var.event_archive_bucket_name
      CRITICAL_EVENTS_TOPIC_ARN = var.critical_events_topic_arn
    }
  }

  depends_on = [aws_cloudwatch_log_group.event_processor]

  tags = {
    Repository = "retail-microservices-eks-platform"
  }
}

resource "aws_lambda_event_source_mapping" "event_processor" {
  event_source_arn                   = var.events_queue_arn
  function_name                      = aws_lambda_function.event_processor.arn
  batch_size                         = 10
  function_response_types            = ["ReportBatchItemFailures"]
  maximum_batching_window_in_seconds = 5
}

resource "aws_iam_role" "event_query_api" {
  name               = "${var.project_name}-${var.environment}-event-query-api-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    Repository = "retail-microservices-eks-platform"
  }
}

resource "aws_iam_role_policy" "event_query_api" {
  name = "${var.project_name}-${var.environment}-event-query-api-policy"
  role = aws_iam_role.event_query_api.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "WriteQueryApiLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.event_query_api.arn}:*"
      },
      {
        Sid    = "ReadMonitoringEvents"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Scan"
        ]
        Resource = var.events_table_arn
      }
    ]
  })
}

resource "aws_lambda_function" "event_query_api" {
  function_name = "${var.project_name}-${var.environment}-event-query-api"
  role          = aws_iam_role.event_query_api.arn
  handler       = "handler.handler"
  runtime       = "python3.12"
  timeout       = 10
  memory_size   = 128

  filename         = data.archive_file.event_query_api.output_path
  source_code_hash = data.archive_file.event_query_api.output_base64sha256

  environment {
    variables = {
      EVENTS_TABLE_NAME = var.events_table_name
    }
  }

  depends_on = [aws_cloudwatch_log_group.event_query_api]

  tags = {
    Repository = "retail-microservices-eks-platform"
  }
}

resource "aws_apigatewayv2_api" "events" {
  name          = "${var.project_name}-${var.environment}-monitoring-api"
  protocol_type = "HTTP"

  tags = {
    Repository = "retail-microservices-eks-platform"
  }
}

resource "aws_apigatewayv2_integration" "events" {
  api_id                 = aws_apigatewayv2_api.events.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.event_query_api.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "list_events" {
  api_id    = aws_apigatewayv2_api.events.id
  route_key = "GET /events"
  target    = "integrations/${aws_apigatewayv2_integration.events.id}"
}

resource "aws_apigatewayv2_route" "get_event" {
  api_id    = aws_apigatewayv2_api.events.id
  route_key = "GET /events/{eventId}"
  target    = "integrations/${aws_apigatewayv2_integration.events.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.events.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Repository = "retail-microservices-eks-platform"
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowApiGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.event_query_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.events.execution_arn}/*/*"
}
