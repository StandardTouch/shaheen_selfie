import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shaheen_selfie/components/dialog.dart';
import 'package:shaheen_selfie/utils/config/logger.dart';
import 'package:shaheen_selfie/utils/messages.dart';
import 'package:shaheen_selfie/utils/services/api_service.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

final formKey = GlobalKey<FormState>();
// GlobalKey stackKey = GlobalKey();

class TransparentView extends ConsumerStatefulWidget {
  const TransparentView({super.key, required this.imageData});
  final ByteBuffer imageData;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransparentViewState();
}

class _TransparentViewState extends ConsumerState<TransparentView> {
  bool isCapturing = false;
  late ScreenshotController screenshotController;
  String selectedMessage =
      DummyMessages.parentMessage; // Default message to "Parent"

  late Rect rect;
  double rotationAngle = 0.0; // State variable for rotation angle
  late Offset center = const Offset(150, 150);
  double width = 100; // Example width, max 80% of parent width
  double height = 100;

  String generateUniqueString() {
    // Create a random number generator
    final Random random = Random();
    String randomString =
        List.generate(10, (_) => random.nextInt(256).toRadixString(16)).join();
    String timestamp = DateFormat('yyyyMMddHHmmssSSS').format(DateTime.now());
    return '$timestamp-$randomString';
  }

  @override
  void initState() {
    screenshotController = ScreenshotController();
    rect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Uint8List uint8list = Uint8List.view(widget.imageData);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff002147),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo.png",
              fit: BoxFit.contain,
              width: 100,
            ),
            Text(
              "Powered By StandardTouch",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.white),
            )
          ],
        ),
        toolbarHeight: 100,
        centerTitle: true,
      ),
      body: Center(
        child: Screenshot(
          controller: screenshotController,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Keep it square or adjust as per your requirement

              return Container(
                margin: const EdgeInsets.all(10),
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xff002147),
                      width: 10,
                    ),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.width / 6,
                      color: const Color(0xff002147),
                      width: double.infinity,
                      child: Image.asset("assets/logo.png"),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/bg.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                alignment: Alignment.bottomRight,
                                height: MediaQuery.of(context).size.width / 15,
                                color: const Color(0xff002147),
                                child: const Row(
                                  children: [
                                    Expanded(
                                        flex: 3,
                                        child: FittedBox(
                                          child: Text(
                                            "Toll Free No: 18001216235",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: FittedBox(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.public,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              "shaheengroup.org",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          TransformableBox(
                            visibleHandles: isCapturing
                                ? {}
                                : {
                                    HandlePosition.left,
                                    HandlePosition.right,
                                    HandlePosition.top,
                                    HandlePosition.bottom,
                                    HandlePosition.topLeft,
                                    HandlePosition.bottomRight,
                                    HandlePosition.topRight,
                                    HandlePosition.bottomLeft
                                  },
                            rect: rect,
                            clampingRect:
                                Offset.zero & MediaQuery.sizeOf(context),
                            onChanged: (result, event) {
                              setState(() {
                                rect = result.rect;
                              });
                            },
                            // Apply rotation using Transform widget
                            contentBuilder: (ctx, rect, flip) =>
                                Transform.rotate(
                              angle: rotationAngle, // Apply the rotation
                              child: Image.memory(
                                uint8list,
                                height: 500,
                              ),
                            ),
                          ),
                          // Rotation Controls
                          if (!isCapturing)
                            Positioned(
                              top: 0,
                              left: MediaQuery.sizeOf(context).width / 3,
                              right: MediaQuery.sizeOf(context).width / 3,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.rotate_left),
                                    onPressed: () {
                                      setState(() {
                                        rotationAngle -=
                                            0.1; // Rotate counter-clockwise
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.rotate_right),
                                    onPressed: () {
                                      setState(() {
                                        rotationAngle +=
                                            0.1; // Rotate clockwise
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        onPressed: () {
          setState(() {
            isCapturing = true;
          });
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (ctx) {
                return ShaheenAlertDialog(
                  widgetController: screenshotController,
                  selectedMessage:
                      selectedMessage, // Pass the selected message to the dialog
                  onMessageChanged: (message) {
                    setState(() {
                      selectedMessage = message!;
                    });
                  },
                );
              });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff002147),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: const Text("Share"),
      ),
    );
  }
}
