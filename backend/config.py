# app/config.py

SCOPES = ["https://www.googleapis.com/auth/spreadsheets"]
SPREADSHEET_ID = "1b-GoXyIc_PLbAx9TWZgmCbWqTl2H9hfElPL2iqIoUeU"
RANGES = {
    "login": "credenciales_usuarios!A:C",
    "clients": "clientes!A:AZ",
    "usuarios": "usuarios!A:E",
    "interactions": "nueva_interaccion!A:K"
}
