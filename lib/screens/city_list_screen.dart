import 'package:flutter/material.dart';
import 'city_details_screen.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  CityListState createState() => CityListState();
}

class CityListState extends State<CityListScreen> {
  final List<String> cities = ['Warszawa', 'Kraków', 'Gdańsk', 'Poznań', 'Wrocław'];
  List<String> filteredCities = [];

  @override
  void initState() {
    super.initState();
    filteredCities = cities; // Domyślnie pokazuj wszystkie miasta
  }

  void _filterCities(String query) {
    setState(() {
      filteredCities = cities
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Miast'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Pole wyszukiwania
            TextField(
              onChanged: _filterCities,
              decoration: InputDecoration(
                labelText: 'Wyszukaj miasto',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Lista miast
            Expanded(
              child: ListView.builder(
                itemCount: filteredCities.length,
                itemBuilder: (ctx, index) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        filteredCities[index],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) =>
                                CityDetailsScreen(cityName: filteredCities[index]),
                          ),
                        );
                      },
                    ),
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
