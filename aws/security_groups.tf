# ── Security Group für die EC2-Instanz ───────────────────
resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Security Group fuer die Homelab App"
  vpc_id      = aws_vpc.main.id

  # ── EINGEHEND (Ingress) ──────────────────────────────────

  # HTTP — offen für alle (App muss erreichbar sein)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
  }

  # HTTPS — offen für alle
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from anywhere"
  }

  # SSH — NUR von deiner eigenen IP! Nicht 0.0.0.0/0!
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]   # z.B. "85.123.45.67/32"
    description = "SSH only from my IP"
  }

  # Prometheus — nur intern erreichbar
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]   # nur aus dem VPC
    description = "Prometheus internal only"
  }

  # Grafana — nur intern erreichbar
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]   # nur aus dem VPC
    description = "Grafana internal only"
  }

  # ── AUSGEHEND (Egress) ───────────────────────────────────
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"             # alles erlaubt
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = { Name = "${var.project_name}-app-sg" }
}
