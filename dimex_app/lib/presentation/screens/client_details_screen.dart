import 'package:dimex_app/presentation/widgets/percentage_card.dart';
import 'package:dimex_app/presentation/widgets/progress_bar.dart';
import 'package:dimex_app/presentation/widgets/text_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'new_interaction_screen.dart';

class ClientDetailsScreen extends StatelessWidget {
  final String clientId;

  ClientDetailsScreen({required this.clientId});

  Future<String> _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('serverIp') ?? 'https://dimex-api.azurewebsites.net';
  }

  double _calculatePercentage(dynamic numerator, dynamic denominator) {
    if (numerator == null || denominator == null || denominator == 0) {
      return 0.0;
    }

    // Convert numeric strings to double if needed
    double numValue = (numerator is String) ? double.tryParse(numerator) ?? 0.0 : numerator.toDouble();
    double denomValue = (denominator is String) ? double.tryParse(denominator) ?? 0.0 : denominator.toDouble();

    if (denomValue == 0) {
      return 0.0; // Avoid division by zero
    }

    // Calculate percentage and round to 2 decimal places
    double percentage = (numValue / denomValue) * 100;
    return double.parse(percentage.toStringAsFixed(2));
  }

  int _calculateTotalContacts(dynamic callCenter, dynamic puertaPuerta, dynamic agenciasEspecializadas) {
    // Convert numeric strings to int if needed
    int callCenterValue = (callCenter is String) ? int.tryParse(callCenter) ?? 0 : callCenter.toInt();
    int puertaPuertaValue = (puertaPuerta is String) ? int.tryParse(puertaPuerta) ?? 0 : puertaPuerta.toInt();
    int agenciasEspecializadasValue = (agenciasEspecializadas is String) 
        ? int.tryParse(agenciasEspecializadas) ?? 0 
        : agenciasEspecializadas.toInt();

    // Calculate total contacts
    int totalContacts = callCenterValue + puertaPuertaValue + agenciasEspecializadasValue;

    return totalContacts;
  }




  Future<Map<String, dynamic>> fetchClientDetails() async {
    final response = await http.get(Uri.parse("https://dimex-api.azurewebsites.net/client/$clientId"));

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Hubo un error al cargar los detalles del cliente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Cliente'),
      ),
      body: FutureBuilder<String>(
        future: _loadCredentials(),
        builder: (context, ipSnapshot) {
          if (ipSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (ipSnapshot.hasError) {
            return Center(child: Text('Error cargando el IP: ${ipSnapshot.error}'));
          }

          return FutureBuilder<Map<String, dynamic>>(
            future: fetchClientDetails(),
            builder: (context, clientSnapshot) {
              if (clientSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (clientSnapshot.hasError) {
                return Center(child: Text('Error: ${clientSnapshot.error}'));
              } else if (!clientSnapshot.hasData || clientSnapshot.data!.isEmpty) {
                return Center(child: Text('No se encontraron detalles del cliente.'));
              }

              final client = clientSnapshot.data!;

              // Calculate percentages
              double ccPercentage = _calculatePercentage(
                client['call_center_atendido'],
                client['gestion_Call Center'],
              );
              double ppPercentage = _calculatePercentage(
                client['puerta_a_puerta_atendido'],
                client['gestion_Gestion Puerta a Puerta'],
              );
              double aePercentage = _calculatePercentage(
                client['agencias_especializadas_atendido'],
                client['gestion_Agencias Especializadas'],
              );

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Card(
                      color: Theme.of(context).cardColor,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: AssetImage('assets/fotos_clientes/imagen_${client['id_foto']}.webp'),
                              backgroundColor: Colors.transparent,
                            ),
                            SizedBox(height: 20),

                            // Contacto Card
                            Card(
                              color: Theme.of(context).colorScheme.secondary,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Container(
                                width: cardWidth,
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Contacto',
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                          fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10),
                                    TextDetails(label: 'Número de Cliente' , value: client['id_cliente']),
                                    TextDetails(label: 'Nombre', value: client['nombre_completo']),
                                    TextDetails(label: 'Correo', value: client['correo']),
                                    TextDetails(label: 'Teléfono', value: client['telefono']),
                                    TextDetails(label: 'Dirección', value: client['direccion'])
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 20),

                            // Propuesta Card
                            Card(
                              color: Theme.of(context).colorScheme.secondary,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Container(
                                width: cardWidth,
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Recomendación Siguiente Interacción',
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                          fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10),
                                    TextDetails(label: 'Vía de Contacto', value: client['mejorGestion']),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Propuesta: ', // Key part
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(255, 27, 83, 29)
                                            ),
                                          ),
                                          TextSpan(
                                            text: client['mejorOferta'].isNotEmpty ? client['mejorOferta'] : 'No information', // Value part
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(255, 27, 83, 29),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 20),

                            // Historial collapsible card
                            ExpansionTile(
                              title: Text(
                                      'Historial',
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                          fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              children: [
                                Container(
                                  width: cardWidth,
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Text(
                                          'Crédito Actual',
                                          style: Theme.of(context).textTheme.bodyMedium!
                                        ),
                                      ),
                                      TextDetails(label: 'Tasa de Interés', value: '${client['tasa interes'] ?? 'No information'}%'),
                                      TextDetails(label: 'Plazo de Meses', value: '${client['Plazo_Meses'] ?? 'No information'}'),
                                      TextDetails(label: 'Línea de Crédito', value: '\$${client['Linea credito'] ?? 'No information'}'),
                                      TextDetails(
                                        label: 'Nivel de Atraso', 
                                        value: client['Nivel de atraso'] == '1_29' 
                                          ? '1-29 días' 
                                          : client['Nivel de atraso'] == '30_89' 
                                            ? '30-89 días' 
                                            : '+90 días'
                                      ),
                                      SizedBox(height: 10),
                                      PaymentCapacityWidget(
                                        capacidadPago: client['capacidad_pago'],
                                        pagoMensual: client['Pago'],
                                      ),
                                      SizedBox(height: 15),
                                      Center(
                                        child: Text(
                                          'Interacciones Pasadas',
                                          style: Theme.of(context).textTheme.bodyMedium!
                                        ),
                                      ),
                                      TextDetails(label: 'Última Gestión', value: '${client['ultimaGestion'] ?? 'No information'}'),
                                      TextDetails(label: 'Cantidad de Interacciones', value: '${_calculateTotalContacts(client['gestion_Agencias Especializadas'], client['gestion_Call Center'], client['gestion_Gestion Puerta a Puerta'])}'),
                                      SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(child: PercentageCard(label: 'CC', value: ccPercentage)),
                                          SizedBox(width: 10),
                                          Expanded(child: PercentageCard(label: 'PP', value: ppPercentage)),
                                          SizedBox(width: 10),
                                          Expanded(child: PercentageCard(label: 'AE', value: aePercentage)),
                                        ],
                                      ),
                                      Text('** Tipo de Gestion. CC: Call Center, PP: Puerta en Puerta, AE: Agente Externo', style: TextStyle(fontSize: 9)),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20),

                            // Button for new interaction
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewInteractionScreen(clientId: client['id_cliente']),
                                  ),
                                );
                              },
                              child: Text('Nueva Interacción'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                                textStyle: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
