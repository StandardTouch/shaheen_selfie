import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_selfie/utils/config/logger.dart';

class WithbgcameraScreen extends ConsumerStatefulWidget {
  const WithbgcameraScreen({super.key});

  @override
  WithbgcameraScreenState createState() => WithbgcameraScreenState();
}

class WithbgcameraScreenState extends ConsumerState<WithbgcameraScreen> {
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
        "withbgview",
        extra: bytes.buffer,
      );
    } catch (e) {
      logger.e(e);
    }
  }

  // Handling the device back button press
  Future<bool> _onWillPop() async {
    // Prevent exiting the app when the back button is pressed
    // You can define the custom behavior here, e.g. navigate to home screen
    context.go('/home');
    return Future.value(false); // Prevents the app from exiting
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,  // Allow popping
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Handle the back button press
          context.go('/home');  // Navigate back to the home screen
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Camera Screen'),
          centerTitle: true,
          backgroundColor: const Color(0xff002147),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate back to the home screen using the router
             Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Colors.black,
        body: FutureBuilder(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final screenSize = MediaQuery.of(context).size;

              const visibleHeightRatio = 0.6; // portion visible for image
              final visibleHeight = screenSize.height * visibleHeightRatio;
              final overlayHeight = screenSize.height - visibleHeight;

              return Stack(
                children: [
                  CameraPreview(_controller),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: overlayHeight / 2,
                    child: Container(color: Colors.black.withOpacity(0.6)),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: overlayHeight / 2,
                    child: Container(color: Colors.black.withOpacity(0.6)),
                  ),
                  Positioned(
                    bottom: 50, // position the button above the bottom overlay
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FloatingActionButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
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
                    ),
                  ),
                ],
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
        ),
      ),
    );
  }
}
