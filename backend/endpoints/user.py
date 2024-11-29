# backend/endpoints/user.py

import re
from fastapi import APIRouter, HTTPException, WebSocket, WebSocketDisconnect
from db.google_sheets_client import get_user_db, get_sheet_data
from config import RANGES
from time import sleep
import json
import openai
from openai import OpenAI
import os
from dotenv import load_dotenv

router = APIRouter()

@router.get("/usuario/{usuario_id}")
async def get_user(usuario_id: str):
    users_sheet = get_sheet_data(RANGES["usuarios"])
    users_data = get_user_db(usuario_id, users_sheet)
    
    if users_data is not None:
        return users_data
    raise HTTPException(status_code=404, detail="User not found")

def load_api_key():
    load_dotenv()
    return os.environ['OPENAI_API_KEY']

# Load the API key
openai.api_key = load_api_key()

client = OpenAI()
thread = client.beta.threads.create()
dimii = client.beta.assistants.retrieve("asst_eQ0bco7YMyjP2ImOmfi768K8")

def get_conversation_chain_mode6(question: str) -> str:
    """
    Processes a question using Conversational Retrieval Chain logic.
    """
    global thread, dimii

    # Send the question to the assistant
    new_question = client.beta.threads.messages.create(
        thread_id=thread.id,
        role="user",
        content=question
    )
    run = client.beta.threads.runs.create_and_poll(
        thread_id=thread.id,
        assistant_id=dimii.id
    )

    # Poll for the result until completed
    while run.status != 'completed':
        sleep(0.5)
        run = client.beta.threads.runs.retrieve(thread_id=thread.id, run_id=run.id)

    # Retrieve the latest message from the thread
    messages = client.beta.threads.messages.list(thread_id=thread.id)
    answer = messages.data[0].content[0].text.value
    return answer

@router.websocket("/ws/chat")
async def websocket_endpoint(websocket: WebSocket):
    """
    WebSocket endpoint to receive questions and send answers using Mode 6 logic.
    """
    await websocket.accept()
    try:
        while True:
            # Receive a message from the WebSocket
            message = await websocket.receive_text()
            print(f"Received message: {message}")

            try:
                # Parse the incoming message
                data = json.loads(message)

                # Validate the message format (Mode 6)
                if isinstance(data, list) and len(data) == 2 and data[0] == 6:
                    question = data[1]

                    # Example of response with HTML tags
                    # cleaned_text = """Además de las quitas y la estrategia de "tus pesos valen más", puedes considerar las siguientes opciones:

                    #         <ol><li><b>Reversiones de cartera</b>: Permiten realizar ajustes de cartera sin contraprestación, lo que puede ayudar a mantener el aforo requerido y mejorar la liquidez.</li></ol>

                    #         <ol><li><b>Amortización acelerada</b>: Implementa un esquema de amortización "full turbo" donde se prioriza el pago del principal, lo que puede incentivar a los clientes a regularizar su situación.</li></ol>

                    #         <ol><li><b>Tasas de prepagos</b>: Ofrece condiciones flexibles para la amortización anticipada de los créditos, lo que puede motivar a los clientes a liquidar sus deudas antes de tiempo.</li></ol>

                    #         <ol><li><b>Instrumentos de cobertura</b>: Utiliza derivados financieros que protejan contra la volatilidad de tasas, lo que puede hacer más atractivos los pagos para los clientes.</li></ol>

                    #         <ol><li><b>Facilidades de pago</b>: Arma planes de pago ajustados a las capacidades de los clientes, permitiendo pagos más accesibles y evitando el incumplimiento.</li></ol>

                    #         Estas estrategias pueden ser útiles para persuadir a los clientes a regularizar sus pagos. Si necesitas más información sobre alguna de estas opciones, házmelo saber."""
                    # cleaned_text =  "Hello World!"

                    # Process the question using the Mode 6 logic
                    answer = get_conversation_chain_mode6(question)

                    # Remove source tags from the answer
                    pattern = r'【\d+[:\d]*†source】'
                    cleaned_text = re.sub(pattern, '', answer)


                     # Example: Convert specific patterns to HTML tags
                    cleaned_text = re.sub(r'\*\*(.*?)\*\*', r'<b>\1</b>', cleaned_text)  # Bold (**text**)
                    cleaned_text = re.sub(r'__(.*?)__', r'<i>\1</i>', cleaned_text)      # Italics (__text__)
                    cleaned_text = re.sub(r'^-\s(.*)', r'<ul><li>\1</li></ul>', cleaned_text, flags=re.M)  # Bulleted list (- item)

                    # Wrap enumerated lists if needed
                    cleaned_text = re.sub(r'^\d+\.\s(.*)', r'<ol><li>\1</li></ol>', cleaned_text, flags=re.M)  # Numbered list

                    
                    # Send the answer back through WebSocket
                    await websocket.send_text(json.dumps({"answer": cleaned_text}))
                    print(f"Sent answer: {cleaned_text}")
                else:
                    await websocket.send_text(json.dumps({"error": "Invalid message format. Expected [6, question]."}))
            except json.JSONDecodeError:
                await websocket.send_text(json.dumps({"error": "Invalid JSON format."}))
            except Exception as e:
                await websocket.send_text(json.dumps({"error": f"Error processing request: {str(e)}"}))
    except WebSocketDisconnect:
        print("WebSocket disconnected.")


