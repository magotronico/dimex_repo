# tests/test_client.py

import pytest
from unittest.mock import patch

# Mock data for clients
mock_clients_data = [
    {
        "id_cliente": "C0001",
        "nombre_completo": "Jane Brown",
        "correo": "jane.brown@gmail.com",
        "telefono": "1234567890",
        "direccion": "Monterrey, N.L.",
        "ultimo_contacto": "31/10/2024",
        "tipo_contacto": "2"
    }
]

@pytest.mark.asyncio
@patch("db.google_sheets_client.get_sheet_data")
async def test_get_client_success(mock_get_sheet_data, client):
    mock_get_sheet_data.return_value = mock_clients_data

    response = await client.get("/client/C0001")
    assert response.status_code == 200
    assert response.json() == mock_clients_data[0]

@pytest.mark.asyncio
async def test_get_client_not_found(client):
    response = await client.get("/client/C9999")
    assert response.status_code == 404
    assert response.json() == {"detail": "Client not found"}
