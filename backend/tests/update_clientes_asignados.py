from googleapiclient.discovery import build
import pandas as pd
from dependencies import get_credentials
from ..db.google_sheets_client import get_sheet_data
from config import SPREADSHEET_ID

def update_sheet_column(range_name: str, values: list):
    """Update a single column in the specified sheet range."""
    creds = get_credentials()
    service = build("sheets", "v4", credentials=creds)
    body = {
        "values": [[value] for value in values]
    }
    result = service.spreadsheets().values().update(
        spreadsheetId=SPREADSHEET_ID,
        range=range_name,
        valueInputOption="RAW",
        body=body
    ).execute()
    return result


