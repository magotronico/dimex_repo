import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'chatbot_screen.dart';
import 'search_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String username = 'Usuario';
  int clientesPorAtenderCount = 0;
  List<dynamic> clientesPorAtender = [];
  List<dynamic> clients = [];
  Map<String, int> nivelCounts = {'1': 0, '2': 0, '3': 0, '4': 0};
  bool isLoading = true;



  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');
      final response = await http.get(Uri.parse("https://dimex-api.azurewebsites.net/usuario/$userId"));

      if (response.statusCode == 200) {
        final details = json.decode(utf8.decode(response.bodyBytes));

        // Decode `clientes_por_atender`
        final List<dynamic> clientIds = details['clientes_por_atender'] is String
            ? jsonDecode(details['clientes_por_atender'])
            : details['clientes_por_atender'] ?? [];

        // Parallelize fetching details for each client
        final List<Future<dynamic>> clientRequests = clientIds.map((clientId) async {
          final clientResponse = await http.get(Uri.parse("https://dimex-api.azurewebsites.net/client/$clientId"));
          if (clientResponse.statusCode == 200) {
            return json.decode(utf8.decode(clientResponse.bodyBytes));
          } else {
            print('Error fetching client details for ID: $clientId');
            return null; // Handle invalid responses
          }
        }).toList();

        // Wait for all requests to complete
        final List<dynamic> clientsData = await Future.wait(clientRequests);

        // Filter out null responses
        final List<dynamic> validClients = clientsData.where((client) => client != null).toList();

        // Update priority counts
        final Map<String, int> tempNivelCounts = {'1': 0, '2': 0, '3': 0, '4': 0};
        for (var client in validClients) {
          String nivel = client['prioridad'] ?? '4'; // Default to '4' if null
          tempNivelCounts[nivel] = (tempNivelCounts[nivel] ?? 0) + 1;
        }

        setState(() {
          username = details['nombre_completo'] ?? 'Usuario';
          clientesPorAtender = validClients;
          clientesPorAtenderCount = validClients.length;
          nivelCounts = tempNivelCounts;
        });
      } else {
        throw Exception('Failed to load user details.');
      }
    } catch (error) {
      setState(() {
        username = 'Usuario';
        clientesPorAtender = [];
        nivelCounts = {'1': 0, '2': 0, '3': 0, '4': 0};
      });
      print(error);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildClientList() {
    return ListView.builder(
      itemCount: clientesPorAtender.length,
      itemBuilder: (context, index) {
        final client = clientesPorAtender[index];
        final nivel = client['prioridad'] ?? '4'; // Default to '4'
        final cardColor = _getPriorityColor(nivel);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: cardColor,
                child: Text(
                  nivel,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                client['nombre_completo'] ?? 'Cliente',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ID: ${client['id_cliente'] ?? 'N/A'}"),
                  Text(
                    "Línea de crédito: \$${client['Linea credito'] ?? '0'}",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/clientDetails',
                  arguments: client['id_cliente'],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String nivel) {
    switch (nivel) {
      case '1':
        return const Color.fromARGB(255, 0, 77, 13); // Dark Green
      case '2':
        return const Color.fromARGB(255, 0, 128, 0); // Standard Green
      case '3':
        return const Color.fromARGB(255, 60, 179, 75); // Medium Green
      case '4':
      default:
        return const Color.fromARGB(255, 144, 238, 144); // Light Green
    }
  }

  Widget _buildHomeContent() {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 450,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hola $username!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2, // Gives more space to the pie chart
                    child: Container(
                      height: 180,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildPieChart(),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 180,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 100) {
                            // Compact layout for very small space
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person, size: 30),
                                SizedBox(height: 4),
                                Text(
                                  "Pendientes",
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "$clientesPorAtenderCount",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            );
                          } else {
                            // Default layout
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person, size: 50),
                                SizedBox(height: 8),
                                Text(
                                  "Pendientes",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "$clientesPorAtenderCount",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                "Clientes Asignados",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildClientList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (Route<dynamic> route) => false,
    );
  }

  void _onTabTapped(int index) {
    if (index == 3) {
      _handleLogout(context);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Widget _buildPieChart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100, // Constrain the pie chart size
          height: 150,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: nivelCounts['1']?.toDouble() ?? 0.0,
                  color: const Color.fromARGB(255, 0, 77, 13),
                  title: '${nivelCounts['1']}',
                  titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                PieChartSectionData(
                  value: nivelCounts['2']?.toDouble() ?? 0.0,
                  color: const Color.fromARGB(255, 0, 128, 0),
                  title: '${nivelCounts['2']}',
                  titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                PieChartSectionData(
                  value: nivelCounts['3']?.toDouble() ?? 0.0,
                  color: const Color.fromARGB(255, 60, 179, 75),
                  title: '${nivelCounts['3']}',
                  titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                PieChartSectionData(
                  value: nivelCounts['4']?.toDouble() ?? 0.0,
                  color: const Color.fromARGB(255, 144, 238, 144),
                  title: '${nivelCounts['4']}',
                  titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
              sectionsSpace: 2, // Add space between chart sections
            ),
          ),
        ),
        SizedBox(width: 8), // Spacing between the chart and legend
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (nivelCounts['1'] != null && nivelCounts['1']! > 0)
                _buildLegendItem(const Color.fromARGB(255, 0, 77, 13), 'Nivel 1'), // Dark Green
              if (nivelCounts['2'] != null && nivelCounts['2']! > 0)
                _buildLegendItem(const Color.fromARGB(255, 0, 128, 0), 'Nivel 2'), // Standard Green
              if (nivelCounts['3'] != null && nivelCounts['3']! > 0)
                _buildLegendItem(const Color.fromARGB(255, 60, 179, 75), 'Nivel 3'), // Medium Green
              if (nivelCounts['4'] != null && nivelCounts['4']! > 0)
                _buildLegendItem(const Color.fromARGB(255, 144, 238, 144), 'Nivel 4'), // Light Green
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/dimex_white.png',
          height: 40,
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeContent(), // Index 0
                SearchScreen(),       // Index 1
                ChatBot(),            // Index 2
                Container(),          // Placeholder for logout
              ],
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
