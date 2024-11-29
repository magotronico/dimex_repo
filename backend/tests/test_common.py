# tests/test_common.py

import pytest

@pytest.mark.asyncio
async def test_hello_world(client):
    response = await client.get("/helloworld/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello World!"}
