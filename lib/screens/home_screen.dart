import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_selfie/utils/config/logger.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.

    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      const CameraDescription(
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
        name: "0",
      ),

      // Define the resolution to use.
      ResolutionPreset.high,
      enableAudio: false,
    );

    _controller.setFlashMode(FlashMode.off);

    _initializeControllerFuture = _controller.initialize();
    // Next, initialize the controller. This returns a Future.

    logger.t("initialize controller value: $_initializeControllerFuture");
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  void takePicture() async {
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Attempt to take a picture and then get the location
      // where the image file is saved.
      final image = await _controller.takePicture();
      if (!context.mounted) return;
      context.pushNamed("preview", pathParameters: {
        "imagePath": image.path,
      });
    } catch (e) {
      // If an error occurs, log the error to the console.
      logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fill this out in the next steps.
    return FutureBuilder(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, display the preview.
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SizedBox(
              width: double.infinity,
              child: CameraPreview(_controller),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
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
          // Handle any errors that occurred during initialization.
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          // Otherwise, display a loading indicator.
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            ),
          );
        }
      },
    );
  }
}
