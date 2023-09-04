#Мы собираемся настроить графану, чтоб она сразу поднималась настроенной, с готовыми дашбордами и прописаным датасорсем(прометеусом)
#Для начала поднимем инстанс
# Экземпляр EC2 для Grafana
resource "aws_instance" "dos13_aderekh_grafana" {
    key_name                    = "adereh"
    ami                         = "ami-08a52ddb321b32a8c"
    instance_type               = "t2.micro"
    subnet_id                   = "subnet-0a2d2ff0b51802509"
    vpc_security_group_ids      = [aws_security_group.dos13_aderekh_prometheus_sg.id]
    associate_public_ip_address = true
    iam_instance_profile        = aws_iam_instance_profile.prometheus_profile_aderekh.name
    user_data = file("grafana.sh")

    provisioner "file" {
        source      = "./monitoring/grafana/"
        destination = "/home/ec2-user/"
        
        connection {
            type         = "ssh"
            user         = "ec2-user"
            private_key  = file("${path.module}/adereh.pem")
            host         = self.public_ip
  }

    }


    depends_on = [aws_instance.dos13_aderekh_prometheus] # Зависимость от инстанса Prometheus

    tags = {
    Name = "dos13_aderekh_grafana"
    }
}