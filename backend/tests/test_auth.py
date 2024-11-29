# tests/test_auth.py

import pytest
from unittest.mock import patch
from httpx import AsyncClient

# Mock data
mock_login_data = [
    {"id_gestor": "G0000", "correo": "john@example.com", "contrasena": "testpass123"},
    {"id_gestor": "G0001", "correo": "gxgnbbgt@gmail.com", "contrasena": "testpass124"},
]

@pytest.mark.asyncio
@patch("db.google_sheets_client.get_sheet_data")
async def test_login_success(mock_get_sheet_data, client: AsyncClient):
    # Set up mock data
    mock_get_sheet_data.return_value = mock_login_data

    # Test login with correct credentials
    response = await client.post("/login/", params={"id": "G0000", "password": "testpass123"})
    
    if response.status_code != 200:
        print(f"Response content: {response.json()}")  # Print response content for debugging
    assert response.status_code == 200, f"Expected 200 OK, got {response.status_code}"


@pytest.mark.asyncio
async def test_login_failure(client: AsyncClient):
    # Test login with incorrect password
    response = await client.post("/login/", params={"id": "G0000", "password": "wrongpass"})
    
    if response.status_code != 401:
        print(f"Response content: {response.json()}")  # Print response content for debugging
    assert response.status_code == 401, f"Expected 401 Unauthorized, got {response.status_code}"
