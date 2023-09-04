# Крч, у нас есть какая-то VPC, какие-то subnets и какой-то autoscaling с инстансами
# чтобы настроить "динамический" мониторинг сделаем следующее:
# 1 Надо добавить в ingress секьюрити группы для инстансов 9100 порт, по нему опрашивает прометеус
# так же настроим секьюриги гр для самого прометеуса :
resource "aws_security_group" "dos13_aderekh_asg_sg" {
  name        = "Dynamic Security Group"
  description = "Dynamic Security Group for asg"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "dos13_aderekh_sg"
  }
}

variable "ports" {
  type    = list
  default = ["80", "443", "22", "9100"]
}

resource "aws_security_group" "dos13_aderekh_prometheus_sg" {
  name        = "dos13_aderekh_prometheus_sg"
  description = "dos13_aderekh_prometheus_sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dos13_aderekh_prometheus_sg"
  }
}

data "aws_iam_policy_document" "prometheus_policy_aderekh" {
  statement {
    actions = [
      "ec2:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "prometheus_policy_aderekh" {
  name        = "prometheus_policy_aderekh"
  description = "A policy that allows Prometheus full access to EC2 instances"
  policy      = data.aws_iam_policy_document.prometheus_policy_aderekh.json
}

resource "aws_iam_instance_profile" "prometheus_profile_aderekh" {
  name = "prometheus_profile_aderekh"
  role = aws_iam_role.prometheus_role_aderekh.name
}

resource "aws_iam_role" "prometheus_role_aderekh" {
  name = "prometheus_role_aderekh"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prometheus_policy_aderekh_attachment" {
  role       = aws_iam_role.prometheus_role_aderekh.name
  policy_arn = aws_iam_policy.prometheus_policy_aderekh.arn
}

resource "aws_instance" "dos13_aderekh_prometheus" {
  key_name                    = "adereh"
  ami                         = "ami-08a52ddb321b32a8c"
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-0a2d2ff0b51802509"
  vpc_security_group_ids      = [aws_security_group.dos13_aderekh_prometheus_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.prometheus_profile_aderekh.name
  user_data                   = file("prometheus.sh")
  depends_on = [ aws_elastic_beanstalk_environment.beanstalkappenv ]

  tags = {
    Name = "dos13_aderekh_prometheus"
  }
}