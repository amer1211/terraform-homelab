# ── VPC — das private Netzwerk in der Cloud ───────────────
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr        # 10.0.0.0/16
  enable_dns_hostnames = true                # EC2 bekommt DNS-Namen
  enable_dns_support   = true

  tags = { Name = "${var.project_name}-vpc" }
}

# ── Internet Gateway — Tor zum Internet ───────────────────
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-igw" }
}

# ── Public Subnet — hier läuft die App ───────────────────
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr  # 10.0.1.0/24
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true   # EC2 bekommt automatisch public IP

  tags = { Name = "${var.project_name}-public-subnet" }
}

# ── Private Subnet — für DBs, interne Services ───────────
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr  # 10.0.2.0/24
  availability_zone = "${var.aws_region}b"

  tags = { Name = "${var.project_name}-private-subnet" }
}

# ── Route Table — leitet Traffic vom public subnet ins Internet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                    # ganzes Internet
    gateway_id = aws_internet_gateway.main.id   # → via IGW
  }

  tags = { Name = "${var.project_name}-public-rt" }
}

# ── Route Table Association — verbindet Subnet mit Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
# Wichtig: Das private Subnet hat KEINE Route zum Internet
# → private Ressourcen sind von außen unerreichbar
