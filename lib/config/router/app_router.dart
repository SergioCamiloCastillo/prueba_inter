import 'package:go_router/go_router.dart';
import 'package:prueba_inter/features/friends/presentation/screens/friend_detail_screen.dart';
import 'package:prueba_inter/features/friends/presentation/screens/friends_screen.dart';
import 'package:prueba_inter/features/locations/presentation/screens/add_location_screens.dart';
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
          state.pathParameters['id']; 
      return FriendDetailScreen(
          idFriend: int.parse(idFriend!)); 
    },
  ),
  GoRoute(
      path: "/locations",
      name: LocationsScreen.name,
      builder: (context, state) => const LocationsScreen(),
      routes: const []),
  GoRoute(
      path: "/add-location",
      name: AddLocationScreen.name,
      builder: (context, state) => const AddLocationScreen(),
      routes: const []),
  GoRoute(
    path: "/location/:id",
    name: LocationDetailScreen.name,
    builder: (context, state) {
      final idLocation =
          state.pathParameters['id']; 
      return LocationDetailScreen(
          idLocation:
              int.parse(idLocation!)); 
    },
  ),
]);
