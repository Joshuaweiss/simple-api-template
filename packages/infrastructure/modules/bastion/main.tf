data "aws_ami" "default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "default" {
  count                  = var.up ? 1 : 0
  ami                    = data.aws_ami.default.id
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  user_data = templatefile("${path.module}/user_data", {
    public_key = var.public_key,
    user_name = var.user_name,
  })

  lifecycle {
    ignore_changes = [ami]
  }

  tags = merge(var.tags, {
    Name = "bastion-host",
  })
}

resource "aws_security_group" "bastion-sg" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "bastion_host",
  })
}

resource "aws_security_group_rule" "bastion-sg-egress" {
  security_group_id = aws_security_group.bastion-sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion-sg-ssh-ingress" {
  security_group_id = aws_security_group.bastion-sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  description       = "Bastion Ingress"
  cidr_blocks       = var.ingress_cidrs
}
