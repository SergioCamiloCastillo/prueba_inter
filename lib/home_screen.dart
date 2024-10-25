import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba_inter/config/router/app_router.dart';

class HomeScreen extends StatelessWidget {
  static const String name = "home-screen";
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F9FD),
        title: const Text(
          'Seleccionar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSelectionCard(
              context,
              icon: Icons.person,
              label: 'Modulo amigos',
              color: Colors.orangeAccent,
              onTap: () {
                context.push('/friends');
              },
            ),
            const SizedBox(height: 20),
            _buildSelectionCard(
              context,
              icon: Icons.location_on,
              label: 'Modulo ubicaciones',
              color: Colors.lightBlueAccent,
              onTap: ()  {
                context.push('/locations');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
           
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
    
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const Spacer(),

              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF1E3A8A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
