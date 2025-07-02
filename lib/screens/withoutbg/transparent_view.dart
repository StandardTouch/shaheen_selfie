import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shaheen_selfie/components/dialog.dart';
import 'package:shaheen_selfie/utils/messages.dart';

final formKey = GlobalKey<FormState>();

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
  String selectedMessage = DummyMessages.messages["Guest"]!;

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
              return Container(
                margin: const EdgeInsets.all(10),
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 246, 243, 243),
                      width: 10,
                    ),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    // Logo Container
                    Container(
                      height: MediaQuery.of(context).size.width / 6,
                      color: const Color.fromARGB(255, 246, 243, 243),
                      width: double.infinity,
                      child: Image.asset("assets/bbflogo.png"),
                    ),
                    // Toll-Free Number and URL Section
                    Container(
                      color: const Color.fromARGB(255, 246, 243, 243),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: FittedBox(
                              child: Text(
                                "Contact No: 9448965656",
                                style: TextStyle(
                                  color: Color(0xff02a859),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: FittedBox(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.public,
                                    color: Color(0xff02a859),
                                  ),
                                  Text(
                                    "bidarbettermentfoundation.org",
                                    style: TextStyle(
                                        color: Color(0xff02a859)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Image with Transparent Box for cropping/rotation
                    Expanded(
                      child: Stack(
                        children: [
                          // Background Image
                          Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/bg.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Transformable Box for cropping/rotation (floating image)
                          Positioned.fill(
                            child: TransformableBox(
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
                              contentBuilder: (ctx, rect, flip) => Transform.rotate(
                                angle: rotationAngle, // Apply the rotation
                                child: Image.memory(
                                  uint8list,
                                  height: 500,
                                ),
                              ),
                            ),
                          ),
                          // Rotation Controls
                          if (!isCapturing)
                            Positioned(
                              top: 20,
                              left: MediaQuery.sizeOf(context).width / 3,
                              right: MediaQuery.sizeOf(context).width / 3,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.rotate_left),
                                    onPressed: () {
                                      setState(() {
                                        rotationAngle -=
                                            0.1; // Rotate counter-clockwise
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.rotate_right),
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
