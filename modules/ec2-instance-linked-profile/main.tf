resource "aws_iam_role" "role" {
    name = var.name
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
    name = "${var.name}-policy"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ${jsonencode(var.allow_actions)},
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "attachment" {
    name = "${var.name}-attachment"
    roles = [ aws_iam_role.role.name ]
    policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "profile" {
    name = "${var.name}-profile"
    role = aws_iam_role.role.name
}
