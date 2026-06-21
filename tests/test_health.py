"""Health check tests."""

from fastapi.testclient import TestClient

from pag.main import app

client = TestClient(app)


def test_health_check() -> None:
    """Test health check endpoint returns healthy status."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


def test_root() -> None:
    """Test root endpoint returns app info."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["message"] == "Programmable API Gateway"
    assert "version" in data
