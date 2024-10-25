import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';
import 'package:prueba_inter/features/locations/infrastructure/datasources/locations_datasource_localdatabase_impl.dart';
import 'package:prueba_inter/features/locations/infrastructure/repositories/locations_repository_impl.dart';
import 'package:prueba_inter/features/locations/presentation/store/locations_store.dart';
import 'package:prueba_inter/features/shared/widgets/card_list.dart';

class LocationsScreen extends StatefulWidget {
  static const name = "locations-screen";

  const LocationsScreen({super.key});

  @override
  _LocationsScreenState createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  late LocationsStore _locationsStore;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    final datasource = LocationsDatasourceLocaldatabaseImpl();
    final repository = LocationsRepositoryImpl(datasource: datasource);
    _locationsStore = LocationsStore(repository);
    _locationsStore.fetchLocations();
  }

  void _deleteLocation(int locationId) async {
    bool success = await _locationsStore.deleteLocation(locationId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ubicación eliminada exitosamente."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al eliminar ubicación."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddLocationScreen() async {
    final result = await GoRouter.of(context).push('/add-location');

    if (result == true) {
      _locationsStore.fetchLocations();
    }
  }

  List<LocationEntity> _filterLocations() {
    if (_searchQuery.isEmpty) {
      return _locationsStore.locations;
    } else {
      return _locationsStore.locations.where((location) {
        return location.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ubicaciones registradas"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Observer(
          builder: (_) {
            final filteredLocations = _filterLocations();
            if (filteredLocations.isEmpty) {
              return const Center(child: Text("No hay ubicaciones."));
            }
            return ListView.builder(
              itemCount: filteredLocations.length,
              itemBuilder: (context, index) {
                final location = filteredLocations[index];
                return CardList(
                  icon: Icons.location_on,
                  title: location.name,
                  subTitle: location.location,
                  onDelete: () {
                    _deleteLocation(location.idLocation!);
                  },
                  colorCard: Colors.blue,
                  onTap: () {
                    context.push('/location/${location.idLocation}');
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLocationScreen,
        tooltip: "Agregar Ubicación",
        child: const Icon(Icons.add_location),
      ),
    );
  }
}
