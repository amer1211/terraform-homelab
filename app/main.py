from fastapi import FastAPI
from fastapi.responses import JSONResponse
import psutil
import os
import datetime

app = FastAPI(
    title="Homelab API",
    description="Deployed mit Docker + GitHub Actions auf Hetzner",
    version="1.0.0"
)

START_TIME = datetime.datetime.utcnow()


@app.get("/")
def root():
    """Einfacher Health-Check."""
    return {
        "status": "ok",
        "message": "Homelab API läuft",
        "deployed_by": "GitHub Actions + Terraform"
    }


@app.get("/health")
def health():
    """Health-Endpoint für Monitoring und Load Balancer."""
    uptime = (datetime.datetime.utcnow() - START_TIME).seconds
    return JSONResponse({
        "status": "healthy",
        "uptime_seconds": uptime,
        "version": os.getenv("APP_VERSION", "dev")
    })


@app.get("/metrics")
def metrics():
    """System-Metriken — Basis für Prometheus später."""
    return {
        "cpu_percent": psutil.cpu_percent(interval=1),
        "memory": {
            "total_mb":     round(psutil.virtual_memory().total / 1024 / 1024),
            "used_mb":      round(psutil.virtual_memory().used  / 1024 / 1024),
            "percent_used": psutil.virtual_memory().percent
        },
        "disk_percent": psutil.disk_usage("/").percent
    }


@app.get("/info")
def info():
    """Deployment-Informationen — zeigt welche Version läuft."""
    return {
        "app_version":   os.getenv("APP_VERSION", "dev"),
        "git_sha":       os.getenv("GIT_SHA", "unknown"),
        "deployed_at":   os.getenv("DEPLOYED_AT", "unknown"),
        "environment":   os.getenv("ENVIRONMENT", "dev")
    }
