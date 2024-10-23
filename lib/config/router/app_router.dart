import 'package:go_router/go_router.dart';
import 'package:prueba_inter/features/friends/presentation/screens/friends_screen.dart';
import 'package:prueba_inter/home_screen.dart';

final appRouter = GoRouter(initialLocation: "/friends", routes: [
  GoRoute(
      path: "/friends",
      name: FriendsScreen.name,
      builder: (context, state) => const FriendsScreen(),
      routes: const []),
]);
