import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import 'city_details_screen.dart';
import 'city_map_screen.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  CityListState createState() => CityListState();
}

class CityListState extends State<CityListScreen> {
  final List<String> initialCities = ['Warszawa', 'Kraków', 'Gdańsk', 'Poznań', 'Wrocław'];
  List<String> filteredCities = [];
  bool isSearching = false;
  String lastQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    filteredCities = initialCities;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, WeatherProvider weatherProvider) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        setState(() {
          filteredCities = [
            ...initialCities,
            ...weatherProvider.favoriteCities.where((city) => !initialCities.contains(city))
          ];
        });
      } else if (!initialCities.contains(query)) {
        _searchCity(query, weatherProvider);
      } else {
        setState(() {
          filteredCities = initialCities
              .where((city) => city.toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      }
    });
  }

  void _searchCity(String query, WeatherProvider weatherProvider) async {
    if (query.isEmpty || query == lastQuery) return;
    lastQuery = query;

    setState(() {
      isSearching = true;
    });

    try {
      await weatherProvider.fetchWeather(query);
      if (!mounted) return;
      setState(() {
        filteredCities = [query];
        isSearching = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie znaleziono miasta: $query')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WeatherWise - Lista Miast'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const CityMapScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (query) => _onSearchChanged(query, weatherProvider),
              decoration: InputDecoration(
                labelText: 'Wyszukaj miasto',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: filteredCities.length,
                itemBuilder: (ctx, index) {
                  final cityName = filteredCities[index];
                  final isFavorite = weatherProvider.isFavorite(cityName);

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        cityName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: !initialCities.contains(cityName)
                          ? IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: isFavorite ? Colors.yellow : Colors.grey,
                        ),
                        onPressed: () {
                          weatherProvider.toggleFavoriteCity(cityName);
                          setState(() {
                            filteredCities = [
                              ...initialCities,
                              ...weatherProvider.favoriteCities.where((city) => !initialCities.contains(city))
                            ];
                          });
                        },
                      )
                          : null,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => CityDetailsScreen(cityName: cityName),
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