# Cloud Homelab — DevOps Portfolio

> Vollständiger Cloud-Stack auf Hetzner: Infrastructure as Code,
> automatisiertes Deployment und Production Monitoring.

## Architektur

[Hier Screenshot oder Diagramm einfügen]

| Schicht        | Technologie                        |
|----------------|------------------------------------|
| Infrastruktur  | Terraform + Hetzner Cloud          |
| CI/CD          | GitHub Actions                     |
| App            | FastAPI + Docker (Multi-Stage)     |
| Registry       | GitHub Container Registry (GHCR)   |
| Monitoring     | Prometheus + Grafana + Node Exp.   |
| State          | Hetzner Object Storage (S3)        |

---

## Was automatisch passiert

```
git push → pytest → Docker Build (120MB) → GHCR → SSH Deploy → Health Check
            ↑                                                          ↓
         Branch Protection                               Prometheus scraped /metrics
```

---

## Projekt 1 — Terraform Infrastruktur

**Was deployed wird:**
- Hetzner CX22 Server (ARM, 2 vCPU, 4 GB RAM)
- Firewall mit SSH / HTTP / HTTPS Regeln
- SSH-Key Verwaltung als Code
- Remote State in Hetzner Object Storage

**Gelernte Konzepte:**
- Idempotenz: `terraform apply` 10× = immer gleiches Ergebnis
- Infrastructure Drift erkennen und beheben
- Secrets via `tfvars` (nie in Git)
- `terraform fmt` + `validate` in GitHub Actions CI

---

## Projekt 2 — CI/CD Pipeline + FastAPI App

**Pipeline-Schritte bei jedem Push:**
1. `pytest` — automatische Tests
2. `docker build` — Multi-Stage Image (~120 MB statt ~900 MB)
3. Push zu GHCR mit Git-SHA als Tag
4. SSH-Deploy auf Hetzner-Server
5. Health-Check: `curl /health` muss 200 zurückgeben

**API Endpoints:**
| Endpoint   | Beschreibung                        |
|------------|-------------------------------------|
| `GET /`    | Status-Check                        |
| `GET /health` | Uptime + Health-Status           |
| `GET /info`   | Git-SHA, Version, Environment    |
| `GET /metrics`| Prometheus-Metriken              |
| `GET /docs`   | Automatische Swagger-UI          |

---

## Projekt 3 — Prometheus + Grafana Monitoring

**Stack via Docker Compose:**
- Prometheus scraped Metriken alle 15 Sekunden
- Node Exporter liefert Server-Metriken (CPU, RAM, Disk)
- Grafana Dashboard ID 1860 — Live-Visualisierung
- Alert-Regeln: App Down, CPU > 80%, RAM > 85%

[Hier Grafana-Dashboard Screenshot einfügen]

---

## Lokale Entwicklung

```bash
# Repo klonen
git clone https://github.com/DEIN-USER/terraform-homelab

# App lokal starten
cd app
docker build -t homelab-api:local .
docker run -p 8000:8000 homelab-api:local

# Monitoring Stack starten
cd monitoring
docker compose up -d
```

---

## Gelernte Konzepte (für das Interview)

- **IaC**: Infrastruktur versioniert, reproduzierbar, reviewbar
- **GitOps-Mindset**: Git ist die einzige Source of Truth
- **Shift Left Security**: Kein Root-Container, Secrets nur als GitHub Secrets
- **Observability**: Metrics → Prometheus → Grafana (RED-Method)
- **Zero-Downtime**: Health-Check nach jedem Deploy
