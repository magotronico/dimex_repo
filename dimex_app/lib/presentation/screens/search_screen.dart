import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  Timer? _debounce;
  WebSocketChannel? channel; // Declare channel variable

  @override
  void initState() {
    super.initState();
    _loadCredentials(); // Load IP address and set up the channel
    _searchController.addListener(_onSearchChanged);
  }

  // Load the stored IP address from shared preferences
  Future<void> _loadCredentials() async {
    channel = WebSocketChannel.connect(
      Uri.parse('wss://dimex-api.azurewebsites.net/ws/search_clients'),
    );

    // Handle incoming data from the WebSocket
    channel!.stream.listen(
      (data) {
        try {
          final decodedData = jsonDecode(data);
          setState(() {
            searchResults = List<Map<String, dynamic>>.from(decodedData);
          });
        } catch (e) {
          // Handle parsing error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data parsing error: $e')),
          );
        }
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $error')),
        );
      },
    );
  }

  // Function to handle search with debouncing
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Only send the search query if the text is not empty
      if (_searchController.text.isNotEmpty && channel != null) {
        channel!.sink.add(_searchController.text); // Send search query after delay
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    channel?.sink.close(status.goingAway);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Busca un cliente por ID, nombre o correo',
                suffixIcon: Icon(Icons.search),
              ),
            ),
            Expanded(
              child: searchResults.isEmpty
                  ? Center(child: Text('No se encontraron clientes. Teclea para buscar.'))
                  : ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final client = searchResults[index];
                        return ExcludeSemantics(
                          child: Card(
                            key: ValueKey(client['id_cliente']), // Add a unique key
                            color: Theme.of(context).cardColor,
                            child: ListTile(
                              title: Text(client['nombre_completo'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Text('ID: ${client['id_cliente']}', style: TextStyle(fontWeight: FontWeight.normal),),
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
                    )
            ),
          ],
        ),
      ),
    );
  }
}
