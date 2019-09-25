# worker iam role

resource "aws_iam_role" "autoscaling" {
  name = "${var.name}-autoscaling"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.name}-worker"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "autoscaling" {
  role       = aws_iam_role.autoscaling.name
  policy_arn = aws_iam_policy.autoscaling.arn
}

resource "aws_iam_policy" "autoscaling" {
  name        = "${module.worker.iam_role_name}-autoscaling"
  description = "Autoscaling policy for cluster ${var.name}"
  policy      = data.aws_iam_policy_document.autoscaling.json
  path        = "/"
}

data "aws_iam_policy_document" "autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${var.name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}
