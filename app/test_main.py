from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_root():
    r = client.get("/")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "healthy"


def test_metrics():
    r = client.get("/metrics")
    assert r.status_code == 200
    assert "http_requests_total" in r.text
    assert "app_cpu_percent" in r.text


def test_info():
    r = client.get("/info")
    assert r.status_code == 200
    data = r.json()
    assert "app_version" in data
    assert "git_sha" in data
