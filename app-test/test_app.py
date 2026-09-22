from fastapi.testclient import TestClient
from app import app

client = TestClient(app)


def test_root_endpoint():
    """Check if the home route responds with 200 OK and expected message."""
    response = client.get("/")
    assert response.status_code == 200
    expected_msg = "Cloud Foundation Service is running"
    assert response.json() == {"message": expected_msg}


def test_health_check_endpoint():
    """Check if the /health endpoint reports healthy status."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}
