import requests

# # Test login
login_response = requests.get("http://127.0.0.1:8000/client/C0080")
print(login_response.json())