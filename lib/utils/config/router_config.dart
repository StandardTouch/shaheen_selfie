import 'dart:typed_data';

import 'package:go_router/go_router.dart';
import 'package:shaheen_selfie/screens/bgselection_screen.dart';
import 'package:shaheen_selfie/screens/withoutbg/home_screen.dart';
import 'package:shaheen_selfie/screens/withoutbg/image_preview.dart';
import 'package:shaheen_selfie/screens/withoutbg/transparent_view.dart';
import 'package:shaheen_selfie/screens/withbg/withbg_view.dart';
import 'package:shaheen_selfie/screens/withbg/withbgcamera_screen.dart';

final router = GoRouter(
  initialLocation: "/home",
  routes: [
    GoRoute(path: "/home", builder: (ctx, state) => const BgSelectionScreen()),
        GoRoute(path: "/removebg", builder: (ctx, state) => const HomeScreen()),
        GoRoute(path: "/withbg", builder: (ctx, state) => const WithbgcameraScreen()),

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
    ),
    
    GoRoute(
      path: "/withbgview",
      name: "withbgview",
      builder: (ctx, state) =>
          WithbgView(imageData: state.extra as ByteBuffer),
    )
  ],
);