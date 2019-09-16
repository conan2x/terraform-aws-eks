# s3

resource "aws_s3_bucket" "buckets" {
  count  = length(var.buckets)
  bucket = "${var.name}-${var.buckets[count.index]}"
  acl    = "private"

  tags = {
    "Name"                              = "${var.name}-${var.buckets[count.index]}"
    "KubernetesCluster"                 = var.name
    "kubernetes.io/cluster/${var.name}" = "owned"
  }
}

resource "aws_iam_role_policy_attachment" "worker-buckets" {
  count      = length(var.buckets)
  role       = module.worker.iam_role_name
  policy_arn = aws_iam_policy.worker-buckets[count.index].arn
}

resource "aws_iam_policy" "worker-buckets" {
  count       = length(var.buckets)
  name        = "${module.worker.iam_role_name}-s3-${var.buckets[count.index]}"
  description = "S3 bucket policy for cluster ${var.name}"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.name}-${var.buckets[count.index]}",
        "arn:aws:s3:::${var.name}-${var.buckets[count.index]}/*"
      ]
    }
  ]
}
EOF

}
