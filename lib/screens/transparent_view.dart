import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shaheen_selfie/utils/config/logger.dart';
import 'package:shaheen_selfie/utils/services/api_service.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

final formKey = GlobalKey<FormState>();
GlobalKey stackKey = GlobalKey();

class TransparentView extends ConsumerStatefulWidget {
  const TransparentView({super.key, required this.imageData});
  final ByteBuffer imageData;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransparentViewState();
}

class _TransparentViewState extends ConsumerState<TransparentView> {
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
      body: RepaintBoundary(
        key: stackKey,
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                "assets/bg.png",
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.memory(uint8list),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        onPressed: () {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (ctx) => const ShaheenAlertDialog());
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

class ShaheenAlertDialog extends ConsumerStatefulWidget {
  const ShaheenAlertDialog({super.key});

  @override
  ConsumerState<ShaheenAlertDialog> createState() => _ShaheenAlertDialogState();
}

class _ShaheenAlertDialogState extends ConsumerState<ShaheenAlertDialog> {
  bool isLoading = false;
  String phoneNumber = "";
  void sharePicture() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });
      // capture image
      final imageBytes = await capturePng();
      // get imageFile
      if (imageBytes != null) {
        final imageFile = await convertToImageFile(imageBytes);
        if (imageFile != null) {
          // host image
          final imageUrl = await APIService.hostImage(imageFile);
          logger.i("ImageUrl: $imageUrl");
          final isSent = await APIService.sendWhatsappMessage(
            mobileNo: phoneNumber,
            imageUrl: imageUrl,
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

  Future<Uint8List?> capturePng() async {
    try {
      RenderRepaintBoundary boundary =
          stackKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      logger.e("error from capturePng", error: e);
      return null;
    }
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
          onPressed: (isLoading)
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
