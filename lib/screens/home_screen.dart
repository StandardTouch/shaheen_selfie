import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_selfie/utils/config/logger.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      const CameraDescription(
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
        name: "0",
      ),
      ResolutionPreset.high,
      enableAudio: false,
    );

    _controller.setFlashMode(FlashMode.off);

    _initializeControllerFuture = _controller.initialize();

    logger.t("initialize controller value: $_initializeControllerFuture");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

 void takePicture() async {
  try {
    await _initializeControllerFuture;
    final image = await _controller.takePicture();
    if (!context.mounted) return;

    // Read the image bytes
    final bytes = await File(image.path).readAsBytes();

    // Navigate directly to transparent screen and pass bytes buffer
    context.pushNamed(
      "transparent",
      extra: bytes.buffer,
    );
  } catch (e) {
    logger.e(e);
  }
}


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final screenSize = MediaQuery.of(context).size;

          // Calculate the area to keep visible for the next screen
          // Example: Next screen image container takes ~70% height; so black overlay covers remaining 30%
          // Adjust percentages to match your next screen layout exactly

          const visibleHeightRatio = 0.7; // portion visible for image
          final visibleHeight = screenSize.height * visibleHeightRatio;
          final overlayHeight = screenSize.height - visibleHeight;

          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                CameraPreview(_controller),
                // Top black overlay
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: overlayHeight / 2,
                  child: Container(color: Colors.black.withOpacity(0.6)),
                ),
                // Bottom black overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: overlayHeight / 2,
                  child: Container(color: Colors.black.withOpacity(0.6)),
                ),
                // Left black overlay (optional if you want side padding)
                // Positioned(
                //   top: overlayHeight / 2,
                //   bottom: overlayHeight / 2,
                //   left: 0,
                //   width: 20,
                //   child: Container(color: Colors.black.withOpacity(0.6)),
                // ),
                // Right black overlay (optional)
                // Positioned(
                //   top: overlayHeight / 2,
                //   bottom: overlayHeight / 2,
                //   right: 0,
                //   width: 20,
                //   child: Container(color: Colors.black.withOpacity(0.6)),
                // ),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              onPressed: takePicture,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                margin: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
