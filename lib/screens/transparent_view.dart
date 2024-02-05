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
import 'package:shaheen_selfie/utils/config/logger.dart';
import 'package:shaheen_selfie/utils/services/api_service.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

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
  late Rect rect;
  late Offset center = Offset(150, 150);
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
                            decoration: BoxDecoration(
                              image: const DecorationImage(
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
                                    const SizedBox(
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
                            contentBuilder: (ctx, rect, flip) => Image.memory(
                              uint8list,
                              height: 500,
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

// ignore: must_be_immutable
class ShaheenAlertDialog extends ConsumerStatefulWidget {
  ShaheenAlertDialog({super.key, required this.widgetController});
  ScreenshotController widgetController;
  @override
  ConsumerState<ShaheenAlertDialog> createState() => _ShaheenAlertDialogState();
}

class _ShaheenAlertDialogState extends ConsumerState<ShaheenAlertDialog> {
  bool isLoading = false;
  String phoneNumber = "";
  void sharePicture() async {
    final cloudinary = Cloudinary.full(
      apiKey: "581365824184465",
      apiSecret: "48xWnkK1rABkTo-9cUCOJaI0fs0",
      cloudName: "djgpfijtr",
    );

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });
      // capture image
      final imageBytes = await capturePng();
      // get imageFile

      final imageFile = await convertToImageFile(imageBytes);

      if (imageFile != null) {
        try {
// host image
          // final imageUrl = await APIService.hostImage(imageFile);
          final uploadResponse =
              await cloudinary.uploadResource(CloudinaryUploadResource(
            filePath: imageFile.path,
            fileBytes: imageFile.readAsBytesSync(),
            resourceType: CloudinaryResourceType.image,
            folder: "shaheen_students",
            fileName: generateUniqueString(),
          ));
          final imageUrl = uploadResponse.secureUrl;
          logger.i("ImageUrl: $imageUrl");
          // send message on whatsapp
          final isSent = await APIService.sendWhatsappMessage(
            mobileNo: phoneNumber,
            imageUrl: imageUrl!,
          );
          if (isSent) {
            if (!context.mounted) return;
            showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.success(message: "Message Sent"),
            );
          } else {
            if (!context.mounted) return;
            showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.error(message: "An Error Occurred"),
            );
          }
        } catch (err) {
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(message: "An Error Occurred"),
          );
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      }

      if (!context.mounted) return;
      context.pop();
      context.go("/home");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Uint8List> capturePng() async {
    final bytes = await widget.widgetController.capture();
    return bytes!;
  }

  Future<File?> convertToImageFile(Uint8List pngBytes) async {
    try {
      // Get the path to the document directory.
      Directory directory = await getApplicationDocumentsDirectory();
      String path = directory.path;
      File imgFile = File('$path/your_image.png');

      // Write the file and wait for the operation to complete
      await imgFile.writeAsBytes(pngBytes);

      // Return the file
      return imgFile;
    } catch (e) {
      logger.e("error from convertToImageFile", error: e);
      // Handle exceptions or return null
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text("Enter Parent's Phone Number"),
      content: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: const InputDecoration(
                    label: Text("Mobile number"), prefixText: "+91"),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.length != 10 ||
                      value.trim().length != 10) {
                    return "Please enter a valid Number";
                  }
                  return null;
                },
                onSaved: (newVal) {
                  phoneNumber = newVal!;
                },
              )
            ],
          )),
      actions: [
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  context.pop();
                },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : sharePicture,
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text("Send Message"),
        ),
      ],
    );
  }
}
