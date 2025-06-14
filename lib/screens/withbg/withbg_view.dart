import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shaheen_selfie/components/dialog.dart';
import 'package:shaheen_selfie/utils/messages.dart';

final formKey = GlobalKey<FormState>();

class WithbgView extends ConsumerStatefulWidget {
  const WithbgView({super.key, required this.imageData});
  final ByteBuffer imageData;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WithbgViewState();
}

class _WithbgViewState extends ConsumerState<WithbgView> {
  bool isCapturing = false;
  late ScreenshotController screenshotController;
  String selectedMessage = DummyMessages.messages["Parent"]!;
 // Default message to "Parent"

  // final List<String> messageOptions = ["Parent", "Child", "Guest", "Member"];

  @override
  void initState() {
    super.initState();
    screenshotController = ScreenshotController();
  }

  @override
  Widget build(BuildContext context) {
    Uint8List uint8list = Uint8List.view(widget.imageData);

    final screenWidth = MediaQuery.of(context).size.width;
    final containerHeight = screenWidth * 1.5; // portrait ratio

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
      body: SafeArea(
        child: Center(
          child: Screenshot(
            controller: screenshotController,
            child: Container(
              margin: const EdgeInsets.all(
                  10), // remove margin to avoid white space
              height: containerHeight,
              width: screenWidth,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xff002147),
                  width: 10,
                ),
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: MemoryImage(uint8list),
                  fit: BoxFit.cover, // cover to fill whole container
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: screenWidth / 6,
                    color: const Color(0xff002147),
                    width: double.infinity,
                    child: Image.asset("assets/logo.png"),
                  ),
                  Expanded(child: Container()), // fill remaining space

                  // Bottom info without fixed height, no Positioned
                  Container(
                    width: double.infinity,
                    color: const Color(0xff002147),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          child: Text(
                            "Toll Free No: 18001216235",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 8),
                        FittedBox(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.public, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                "shaheengroup.org",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                onMessageChanged: (message) {
                  setState(() {
                    selectedMessage = message!;
                    print(
                        'Updated selected message: $selectedMessage'); // Pass the selected message to the dialog
                  });
                },
                selectedMessage: selectedMessage,
              );
            },
          );
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
