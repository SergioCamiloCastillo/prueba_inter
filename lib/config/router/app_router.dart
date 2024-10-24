import 'package:go_router/go_router.dart';
import 'package:prueba_inter/features/friends/presentation/screens/friend_detail_screen.dart';
import 'package:prueba_inter/features/friends/presentation/screens/friends_screen.dart';
import 'package:prueba_inter/features/locations/presentation/screens/location_detail_screen.dart';
import 'package:prueba_inter/features/locations/presentation/screens/locations_screens.dart';
import 'package:prueba_inter/home_screen.dart';

final appRouter = GoRouter(initialLocation: "/", routes: [
  GoRoute(
      path: "/",
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
      routes: const []),
  GoRoute(
      path: "/friends",
      name: FriendsScreen.name,
      builder: (context, state) => const FriendsScreen(),
      routes: const []),
  GoRoute(
    path: "/friend/:id",
    name: FriendDetailScreen.name,
    builder: (context, state) {
      final idFriend =
          state.pathParameters['id']; // Extrae el parámetro 'id' de la ruta
      return FriendDetailScreen(
          idFriend: int.parse(idFriend!)); // Pasa el id a FriendDetailScreen
    },
  ),
  GoRoute(
      path: "/locations",
      name: LocationsScreen.name,
      builder: (context, state) => const LocationsScreen(),
      routes: const []),
  GoRoute(
    path: "/location/:id",
    name: LocationDetailScreen.name,
    builder: (context, state) {
      final idLocation =
          state.pathParameters['id']; // Extrae el parámetro 'id' de la ruta
      return LocationDetailScreen(
          idLocation:
              int.parse(idLocation!)); // Pasa el id a FriendDetailScreen
    },
  ),
]);
