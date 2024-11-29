import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class NewInteractionScreen extends StatefulWidget {
  final String clientId;

  NewInteractionScreen({required this.clientId});

  @override
  _NewInteractionScreenState createState() => _NewInteractionScreenState();
}

class _NewInteractionScreenState extends State<NewInteractionScreen> {
  bool interactionAchieved = false;
  bool agreementAchieved = false;
  String? selectedOffer;
  DateTime? nextPaymentDate;
  int? interestRate, termMonths;
  double? payment;
  String _contactMethod = '1';
  final TextEditingController _commentsController = TextEditingController();

  final List<String> offerOptions = [
    'Tus Pesos Valen Más',
    'Reestructura del Crédito',
    'Quita / Castigo',
    'Pago sin Beneficio'
  ];

  Future<void> _submitInteraction() async {
    // Check if all required fields are filled out
    if (
        (agreementAchieved && selectedOffer == null) ||
        (selectedOffer == 'Reestructura del Crédito' && (interestRate == null || termMonths == null || payment == null || nextPaymentDate == null)) ||
        (selectedOffer == 'Quita / Castigo' && (payment == null || nextPaymentDate == null)) ||
        ((selectedOffer == 'Pago sin Beneficio' || selectedOffer == 'Tus Pesos Valen Más') && nextPaymentDate == null)
        ) {
      _showSnackbar('Por favor de completar todos los campos requeridos.');
      return;
    }

    final String url = 'https://dimex-api.azurewebsites.net/nueva_interaccion';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    final String interactionId = 'I${DateTime.now().millisecondsSinceEpoch}';
    final String createdAt = DateFormat('hh:mm:ss a').format(DateTime.now());

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          'id_interaccion': interactionId,
          'created_at': createdAt,
          'id_cliente': widget.clientId,
          'id_usuario': userId,
          'via_contacto': _contactMethod,
          'interaccion_lograda': interactionAchieved,
          'acuerdo_logrado': agreementAchieved,
          'oferta_cobranza': selectedOffer,
          'fecha_prox_pago': nextPaymentDate != null ? DateFormat('yyyy-MM-dd').format(nextPaymentDate!) : null,
          'pago': payment,
          'tasa_interes': interestRate,
          'plazo_meses': termMonths,
          'comentarios': _commentsController.text,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackbar('Se guardó correctamente la nueva interacción.');
        Navigator.pop(context);
      } else {
        _showSnackbar('Hubo un fallo en guardar la nueva interacción: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showSnackbar('Ocurrió un error: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null && picked != nextPaymentDate) {
      setState(() {
        nextPaymentDate = picked;
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Interacción'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Se logró una interacción con el cliente?'),
              Switch(
                value: interactionAchieved,
                onChanged: (value) {
                  setState(() {
                    interactionAchieved = value;
                    agreementAchieved = false; // Reset following fields
                    selectedOffer = null;
                    nextPaymentDate = null;
                    interestRate = null;
                    termMonths = null;
                    payment = null;
                  });
                },
              ),
              if (interactionAchieved) ...[
                SizedBox(height: 20),
                Text('¿Se logró un acuerdo con el cliente?'),
                Switch(
                  value: agreementAchieved,
                  onChanged: (value) {
                    setState(() {
                      agreementAchieved = value;
                      selectedOffer = null; // Reset following fields
                      nextPaymentDate = null;
                      interestRate = null;
                      termMonths = null;
                      payment = null;
                    });
                  },
                ),
              ],
              if (agreementAchieved) ...[
                SizedBox(height: 20),
                Text('¿Qué tipo de acuerdo se logró?'),
                DropdownButton<String>(
                  value: selectedOffer,
                  items: offerOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedOffer = value;
                    });
                  },
                  hint: Text('Seleccionar tipo de acuerdo'),
                ),
                SizedBox(height: 20),
                Text('Fecha del próximo pago'),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Text(
                      nextPaymentDate == null
                          ? 'Seleccionar fecha'
                          : DateFormat('yyyy-MM-dd').format(nextPaymentDate!),
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (selectedOffer == 'Reestructura del Crédito') ...[
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Tasa de Interés (%)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      interestRate = int.tryParse(value);
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Plazo (Meses)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      termMonths = int.tryParse(value);
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Pago (\$)'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      payment = double.tryParse(value);
                    },
                  ),
                ],
                if (selectedOffer == 'Quita / Castigo') ...[
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Pago (\$)'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      payment = double.tryParse(value);
                    },
                  ),
                ],
              ],
              SizedBox(height: 20),
              TextField(
                controller: _commentsController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Comentarios',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitInteraction,
                child: Text('Enviar Nueva Interacción'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
