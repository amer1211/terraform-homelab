from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse, Response
import psutil, os, datetime, time
from prometheus_client import (
    Counter, Histogram, Gauge,
    generate_latest, CONTENT_TYPE_LATEST
)

app = FastAPI(title="Homelab API", version="1.0.0")
START_TIME = datetime.datetime.utcnow()

# ── Prometheus Metriken definieren ─────────────────────────
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Anzahl HTTP Requests',
    ['method', 'endpoint', 'status_code']
)
REQUEST_LATENCY = Histogram(
    'http_request_duration_seconds',
    'Request-Dauer in Sekunden',
    ['endpoint']
)
CPU_GAUGE = Gauge('app_cpu_percent', 'CPU-Auslastung der App')
MEMORY_GAUGE = Gauge('app_memory_mb', 'RAM-Nutzung der App in MB')


# ── Middleware: zählt jeden Request ───────────────────────
@app.middleware("http")
async def track_requests(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = time.time() - start

    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.url.path,
        status_code=response.status_code
    ).inc()
    REQUEST_LATENCY.labels(
        endpoint=request.url.path
    ).observe(duration)
    return response


# ── Endpoints ──────────────────────────────────────────────
@app.get("/")
def root():
    return {"status": "ok", "message": "Homelab API läuft"}


@app.get("/health")
def health():
    uptime = (datetime.datetime.utcnow() - START_TIME).seconds
    return JSONResponse({"status": "healthy", "uptime_seconds": uptime})


@app.get("/info")
def info():
    return {
        "app_version": os.getenv("APP_VERSION", "dev"),
        "git_sha":     os.getenv("GIT_SHA", "unknown"),
        "environment": os.getenv("ENVIRONMENT", "dev")
    }


@app.get("/metrics")
def metrics():
    # System-Metriken aktualisieren
    CPU_GAUGE.set(psutil.cpu_percent(interval=1))
    MEMORY_GAUGE.set(psutil.virtual_memory().used / 1024 / 1024)

    # Prometheus-Format zurückgeben (kein JSON!)
    return Response(
        content=generate_latest(),
        media_type=CONTENT_TYPE_LATEST
    )
