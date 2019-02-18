# eks worker

resource "aws_launch_template" "worker-spot" {
  count = "${var.launch_template_enable ? length(var.mixed_instances) != 2 ? 1 : 0 : 0}"

  name_prefix   = "${local.lower_name}-spot-"
  image_id      = "${data.aws_ami.worker.id}"
  instance_type = "${var.instance_type}"
  user_data     = "${base64encode(local.userdata)}"

  key_name = "${var.key_path != "" ? "${local.lower_name}-worker" : "${var.key_name}"}"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type           = "${var.volume_type}"
      volume_size           = "${var.volume_size}"
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    name = "${aws_iam_instance_profile.worker.name}"
  }

  network_interfaces {
    delete_on_termination = true
    security_groups       = ["${aws_security_group.worker.id}"]
  }

  instance_market_options {
    market_type = "spot"
  }
}

resource "aws_autoscaling_group" "worker-spot" {
  count = "${var.launch_template_enable ? length(var.mixed_instances) != 2 ? 1 : 0 : 0}"

  name = "${local.lower_name}-spot"

  min_size = "${var.min}"
  max_size = "${var.max}"

  vpc_zone_identifier = ["${var.subnet_ids}"]

  launch_template = {
    id      = "${aws_launch_template.worker-spot.id}"
    version = "$$Latest"
  }

  tag {
    key                 = "launch_type"
    value               = "spot"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${local.lower_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${local.lower_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = ""
    propagate_at_launch = true
  }
}
