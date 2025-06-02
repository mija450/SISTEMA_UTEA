import 'package:flutter/material.dart';

class BuscarMenuScreen extends StatefulWidget {
  @override
  _BuscarMenuScreenState createState() => _BuscarMenuScreenState();
}

class _BuscarMenuScreenState extends State<BuscarMenuScreen> {
  final List<String> items = [
    'Pizza',
    'Hamburguesa',
    'Tacos',
    'Ensalada',
    'Sushi',
    'Pasta',
    'Postre',
    'Bebidas',
  ];

  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar en el Menú'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: items
                    .where((item) => item.toLowerCase().contains(searchText))
                    .length,
                itemBuilder: (context, index) {
                  final filteredItems = items
                      .where((item) => item.toLowerCase().contains(searchText))
                      .toList();
                  return ListTile(
                    title: Text(filteredItems[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}