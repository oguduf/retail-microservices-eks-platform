resource "aws_launch_template" "workers" {
  name_prefix            = "${var.cluster_name}-workers-"
  update_default_version = true

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name      = "${var.cluster_name}-worker"
      NodeGroup = "${var.cluster_name}-default"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "${var.cluster_name}-worker-volume"
    }
  }
}