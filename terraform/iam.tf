resource "aws_iam_role" "role" {
  name               = "${var.prefix}-${terraform.workspace}"
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

  tags = {
    Name        = "${var.prefix}-${terraform.workspace}"
    environment = terraform.workspace
    group       = var.prefix
  }
}

resource "aws_iam_instance_profile" "profile" {
  name = "${var.prefix}-${terraform.workspace}"
  role = aws_iam_role.role.name
}

resource "aws_iam_role_policy" "policy" {
  name   = "${var.prefix}-${terraform.workspace}"
  role   = aws_iam_role.role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
		{
			"Effect": "Allow",
			"Action": [
					"s3:*",
					"ssm:DescribeAssociation",
					"ssm:GetDeployablePatchSnapshotForInstance",
					"ssm:GetDocument",
					"ssm:DescribeDocument",
					"ssm:GetManifest",
					"ssm:GetParameters",
					"ssm:ListAssociations",
					"ssm:ListInstanceAssociations",
					"ssm:PutInventory",
					"ssm:PutComplianceItems",
					"ssm:PutConfigurePackageResult",
					"ssm:UpdateAssociationStatus",
					"ssm:UpdateInstanceAssociationStatus",
					"ssm:UpdateInstanceInformation",
					"ssmmessages:CreateControlChannel",
					"ssmmessages:CreateDataChannel",
					"ssmmessages:OpenControlChannel",
					"ssmmessages:OpenDataChannel",
					"ec2:DetachVolume",
          "ec2:AttachVolume",
          "ec2:CopySnapshot",
          "ec2:DeleteSnapshot",
          "ec2:DescribeInstances",
          "ec2:DeleteTags",
          "ec2:DescribeTags",
          "ec2:DescribeSnapshotAttribute",
          "ec2:CreateTags",
          "ec2:ResetSnapshotAttribute",
          "ec2:ImportSnapshot",
          "ec2:DescribeSnapshots",
          "ec2:DescribeVolumeAttribute",
          "ec2:DescribeImportSnapshotTasks",
          "ec2:DescribeVolumeStatus",
          "ec2:ModifySnapshotAttribute",
          "ec2:DescribeVolumes",
          "ec2:CreateSnapshot"
			],
			"Resource": "*"
		},
		{
      "Effect":"Allow",
      "Action":[
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource":"*",
      "Condition":{
        "ForAllValues:StringLike":{
          "ses:Recipients":[
            "*@${var.root_domain}"
          ]
        }
      }
		}
  ]
}
EOF
}
