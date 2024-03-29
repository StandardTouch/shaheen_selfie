import 'dart:typed_data';

import 'package:go_router/go_router.dart';
import 'package:shaheen_selfie/screens/home_screen.dart';
import 'package:shaheen_selfie/screens/image_preview.dart';
import 'package:shaheen_selfie/screens/transparent_view.dart';

final router = GoRouter(
  initialLocation: "/home",
  routes: [
    GoRoute(path: "/home", builder: (ctx, state) => const HomeScreen()),
    GoRoute(
      path: "/preview/:imagePath",
      name: "preview",
      builder: (ctx, state) =>
          ImagePreview(imagePath: state.pathParameters["imagePath"]!),
    ),
    GoRoute(
      path: "/transparent",
      name: "transparent",
      builder: (ctx, state) =>
          TransparentView(imageData: state.extra as ByteBuffer),
    )
  ],
);
