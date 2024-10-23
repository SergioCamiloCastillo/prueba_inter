import 'package:go_router/go_router.dart';
import 'package:prueba_inter/features/friends/presentation/screens/friend_detail_screen.dart';
import 'package:prueba_inter/features/friends/presentation/screens/friends_screen.dart';
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
]);
