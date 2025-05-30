import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shaheen_selfie/utils/config/logger.dart';
import 'package:shaheen_selfie/utils/services/api_service.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

final formKey = GlobalKey<FormState>();

class TransparentView extends ConsumerStatefulWidget {
  const TransparentView({super.key, required this.imageData});
  final ByteBuffer imageData;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TransparentViewState();
}

class _TransparentViewState extends ConsumerState<TransparentView> {
  bool isCapturing = false;
  late ScreenshotController screenshotController;

  String generateUniqueString() {
    final Random random = Random();
    String randomString = List.generate(10, (_) => random.nextInt(256).toRadixString(16)).join();
    String timestamp = DateFormat('yyyyMMddHHmmssSSS').format(DateTime.now());
    return '$timestamp-$randomString';
  }

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
            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),
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
            margin:const EdgeInsets.all(10), // remove margin to avoid white space
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
                fit: BoxFit.cover,  // cover to fill whole container
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
                  child:const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
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

      final imageBytes = await capturePng();
      final imageFile = await convertToImageFile(imageBytes);

      if (imageFile != null) {
        try {
          final uploadResponse = await cloudinary.uploadResource(
            CloudinaryUploadResource(
              filePath: imageFile.path,
              fileBytes: imageFile.readAsBytesSync(),
              resourceType: CloudinaryResourceType.image,
              folder: "shaheen_students",
              fileName: generateUniqueString(),
            ),
          );
          final imageUrl = uploadResponse.secureUrl;
          logger.i("ImageUrl: $imageUrl");

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
          if (!context.mounted) return;
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
      Directory directory = await getApplicationDocumentsDirectory();
      String path = directory.path;
      File imgFile = File('$path/your_image.png');

      await imgFile.writeAsBytes(pngBytes);

      return imgFile;
    } catch (e) {
      logger.e("error from convertToImageFile", error: e);
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
        ),
      ),
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
          child:
              isLoading ? const CircularProgressIndicator() : const Text("Send Message"),
        ),
      ],
    );
  }
}
