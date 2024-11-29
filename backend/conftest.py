# # backend/conftest.py

import pytest
from httpx import AsyncClient
from httpx import ASGITransport
from main import app

@pytest.fixture
async def client():
    transport = ASGITransport(app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        yield client
