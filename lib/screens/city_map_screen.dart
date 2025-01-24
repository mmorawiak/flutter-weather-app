import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'city_details_screen.dart';

class CityMapScreen extends StatefulWidget {
  const CityMapScreen({super.key});

  @override
  CityMapScreenState createState() => CityMapScreenState();
}

class CityMapScreenState extends State<CityMapScreen> {
  final Map<String, LatLng> cityCoordinates = {
    'Warszawa': LatLng(52.2297, 21.0122),
    'Kraków': LatLng(50.0647, 19.9450),
    'Gdańsk': LatLng(54.3521, 18.6464),
    'Poznań': LatLng(52.4064, 16.9252),
    'Wrocław': LatLng(51.1079, 17.0385),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa miast'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(51.10418, 17.00643),
          zoom: 6.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: cityCoordinates.entries.map((entry) {
              return Marker(
                point: entry.value,
                builder: (ctx) => GestureDetector(
                  onTap: () {
                    // Bezpieczna nawigacja
                    if (mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => CityDetailsScreen(
                            cityName: entry.key,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
