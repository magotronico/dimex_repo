# backend/send_msm/snd_msm.py

import os
from twilio.rest import Client
from dotenv import load_dotenv

# Load environment variables from the .env file
load_dotenv()

# Retrieve credentials and phone number from environment variables
account_sid = os.getenv('TWILIO_ACCOUNT_SID')
auth_token = os.getenv('TWILIO_AUTH_TOKEN')
twilio_phone_number = os.getenv('TWILIO_PHONE_NUMBER')

def send_agreement_message(acuerdo: int = None, nombre: str = None, amount: float = None, fecha: str = None, recipient_number: str = None, interes: int = None, meses: int = None):
    # 1: Tus Pesos Valen Más | 2: Pago sin Beneficio | 3: Quita / Castigo | 4: Reestructura del Crédito
    client = Client(account_sid, auth_token)

    # Message templates
    message_template_1 = (
        f"Estimado/a {nombre},\n\n"
        f"Agradecemos su colaboración con Dimex. A continuación, le compartimos un resumen del acuerdo de hoy. "
        f"Como recordatorio, su próximo pago de ${amount} está programado para el {fecha}. Con este pago se asegura estar al corriente. Apartir del pago siguiente su pago deberá ser lo regular de ${amount * 2}\n\n"
        f"Para cualquier consulta, no dude en comunicarse con nosotros a través del correo unidadespecializada@dimex.mx "
        f"o al teléfono 81 1247 8686.\n\n"
        f"Atentamente,\nEquipo de Atención al Cliente Dimex."
    )
    message_template_2 = (
        f"Estimado/a {nombre},\n\n"
        f"Agradecemos su colaboración con Dimex. A continuación, le compartimos un resumen del acuerdo de hoy. "
        f"Como recordatorio, su próximo pago de ${amount} está programado para el {fecha}.\n\n"
        f"Para cualquier consulta, no dude en comunicarse con nosotros a través del correo unidadespecializada@dimex.mx "
        f"o al teléfono 81 1247 8686.\n\n"
        f"Atentamente,\nEquipo de Atención al Cliente Dimex."
    )
    message_template_3 = (
        f"Estimado/a {nombre},\n\n"
        f"Agradecemos su colaboración con Dimex. A continuación, le compartimos un resumen del acuerdo de hoy. "
        f"Como recordatorio, su próximo pago de ${amount} está programado para el {fecha}. Con este pago se termina la deuda acumulada.\n\n"
        f"Para cualquier consulta, no dude en comunicarse con nosotros a través del correo unidadespecializada@dimex.mx "
        f"o al teléfono 81 1247 8686.\n\n"
        f"Atentamente,\nEquipo de Atención al Cliente Dimex."
    )
    message_template_4 = (
        f"Estimado/a {nombre},\n\n"
        f"Agradecemos su colaboración con Dimex. A continuación, le compartimos un resumen del acuerdo de hoy. "
        f"Como recordatorio, la reestructuración del crédito queda en pagos de ${amount} con una tasa de interes del {interes}% a {meses} meses.\n\n"
    )

    # Send message
    if acuerdo == 1:
        message_template = message_template_1
    elif acuerdo == 2:
        message_template = message_template_2
    elif acuerdo == 3:
        message_template = message_template_3
    elif acuerdo == 4:
        message_template = message_template_4
    else:
        print("Invalid agreement type")

    # Send message
    message = client.messages.create(
        body=message_template,
        from_=twilio_phone_number,
        to=recipient_number
    )

    print(f"Message sent to {nombre}. SID: {message.sid}")

def print_agreement_message(acuerdo: int = None, nombre: str = None, amount: float = None, fecha: str = None, recipient_number: str = None, interes: int = None, meses: int = None):
    # 1: Tus Pesos Valen Más | 2: Pago sin Beneficio | 3: Quita / Castigo | 4: Reestructura del Crédito
    
    # Message templates
    message_template_1 = (
        f"Estimado/a {nombre},\n\n"
        f"Agradecemos su colaboración con Dimex. A continuación, le compartimos un resumen del acuerdo de hoy. "
        f"Como recordatorio, su próximo pago de ${amount} está programado para el {fecha}. Con este pago se asegura estar al corriente. Apartir del pago siguiente su pago deberá ser lo regular de ${amount * 2}\n\n"
        f"Para cualquier consulta, no dude en comunicarse con nosotros a través del correo unidadespecializada@dimex.mx "
        f"o al teléfono 81 1247 8686.\n\n"
        f"Atentamente,\nEquipo de Atención al Cliente Dimex."
    )
    message_template_2 = (
        f"Estimado/a {nombre},\n\n"
        f"Agradecemos su colaboración con Dimex. A continuación, le compartimos un resumen del acuerdo de hoy. "
        f"Como recordatorio, su próximo pago de ${amount} está programado para el {fecha}.\n\n"
        f"Para cualquier consulta, no dude en comunicarse con nosotros a través del correo unidadespecializada@dimex.mx "
        f"o al teléfono 81 1247 8686.\n\n"
        f"Atentamente,\nEquipo de Atención al Cliente Dimex."
    )
    message_template_3 = (
        f"Estimado/a {nombre},\n\n"
        f"Agradecemos su colaboración con Dimex. A continuación, le compartimos un resumen del acuerdo de hoy. "
        f"Como recordatorio, su próximo pago de ${amount} está programado para el {fecha}. Con este pago se termina la deuda acumulada.\n\n"
        f"Para cualquier consulta, no dude en comunicarse con nosotros a través del correo unidadespecializada@dimex.mx "
        f"o al teléfono 81 1247 8686.\n\n"
        f"Atentamente,\nEquipo de Atención al Cliente Dimex."
    )
    message_template_4 = (
        f"Estimado/a {nombre},\n\n"
        f"Agradecemos su colaboración con Dimex. A continuación, le compartimos un resumen del acuerdo de hoy. "
        f"Como recordatorio, la reestructuración del crédito queda en pagos de ${amount} con una tasa de interes del {interes}% a {meses} meses.\n\n"
    )

    # Send message
    if acuerdo == 1:
        print(f"Message to {recipient_number}:\n{message_template_1}")
    elif acuerdo == 2:
        print(f"Message to {recipient_number}:\n{message_template_2}")
    elif acuerdo == 3:
        print(f"Message to {recipient_number}:\n{message_template_3}")
    elif acuerdo == 4:
        print(f"Message to {recipient_number}:\n{message_template_4}")
    else:
        print("Invalid agreement type")

def send_hello():
    print("Hello from Twilio!")

if __name__ == "__main__":
    send_hello()