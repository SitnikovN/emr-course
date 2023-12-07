data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "emr_security_group" {
  name        = "emr_security_group"
  description = "Security group for EMR to allow SSH inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace this with your IP to restrict access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "emr_security_group"
  }
}

resource "aws_iam_instance_profile" "demo_emr_ec2_instance_profile" {
  name = "demo_emr_ec2_instance_profile"
  role = aws_iam_role.course-emr_ec2_instance_role.name
}

resource "aws_iam_role" "course-emr_ec2_instance_role" {
  name = "emr_ec2_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "emr_ec2_instance_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
  role       = aws_iam_role.course-emr_ec2_instance_role.name
}

resource "aws_iam_role_policy_attachment" "emr_service_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
  role       = aws_iam_role.emr_course_service_role.name
}

#
resource "aws_iam_role" "emr_course_service_role" {
  name = "emr_course_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "elasticmapreduce.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
##
resource "aws_emr_cluster" "course-cluster-demo" {
  name          = "course-cluster-demo"
  release_label = "emr-6.13.0"
  applications  = ["Spark","JupyterEnterpriseGateway"]


  termination_protection            = false
  keep_job_flow_alive_when_no_steps = true

  ec2_attributes {
    subnet_id = var.emr_subnet_id
    emr_managed_master_security_group = aws_security_group.emr_security_group.id
    emr_managed_slave_security_group  = aws_security_group.emr_security_group.id
    key_name = var.emr_key_name
    instance_profile = aws_iam_instance_profile.demo_emr_ec2_instance_profile.name
  }

  configurations_json = jsonencode([
    {
      Classification = "spark-hive-site",
      Properties     = {
        "hive.metastore.client.factory.class" = "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
      }
    }
  ])

  master_instance_group {
    instance_type = "m5.xlarge"
  }

  core_instance_group {
    instance_type  = "m5.xlarge"
    instance_count = 2

    ebs_config {
      size                 = "15"
      type                 = "gp3"
      volumes_per_instance = 1
    }
  }
  service_role = aws_iam_role.emr_course_service_role.arn
  depends_on = [aws_lambda_function.eip-assigner-function]
  tags = {
    env  = "PROD"
  }
}

resource "aws_emr_managed_scaling_policy" "demo-emr-policy" {
  cluster_id = aws_emr_cluster.course-cluster-demo.id
  compute_limits {
    unit_type                       = "Instances"
    minimum_capacity_units          = 2
    maximum_capacity_units          = 4
  }
}