# ── SSH Key Pair — dein lokaler Key in AWS registrieren ──
resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-key"
  public_key = file("~/.ssh/id_ed25519.pub")  # dein bestehender Key
}

# ── EC2 Instanz ───────────────────────────────────────────
resource "aws_instance" "app" {
  ami                    = var.ami_id           # Ubuntu 22.04 Frankfurt
  instance_type          = var.instance_type   # t2.micro (Free Tier)
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]
  key_name               = aws_key_pair.deployer.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # Docker via Cloud-Init installieren (wie bei Hetzner!)
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
    apt-get install -y docker-compose-plugin
    # AWS CLI installieren (nutzt automatisch die IAM Role)
    snap install aws-cli --classic
    echo "Setup complete" > /var/log/cloud-init-done.log
  EOF

  root_block_device {
    volume_size = 20          # 20 GB Storage (Free Tier: 30 GB)
    volume_type = "gp3"
  }

  tags = {
    Name        = "${var.project_name}-server"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
