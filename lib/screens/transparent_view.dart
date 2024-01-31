import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
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
  late Rect rect = Rect.fromCenter(
    center: MediaQuery.of(context).size.center(Offset.zero),
    width: 300,
    height: MediaQuery.of(context).size.width,
  );
  bool isCapturing = false;
  WidgetsToImageController widgetController = WidgetsToImageController();
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
        child: WidgetsToImage(
          controller: widgetController,
          child: Container(
            margin: const EdgeInsets.all(10),
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xff002147),
                  width: 10,
                ),
                borderRadius: BorderRadius.circular(10)),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("assets/bg.png"),
                    fit: BoxFit.cover,
                  )),
                ),
                TransformableBox(
                  cornerHandleBuilder: (ctx, handle) => isCapturing
                      ? const SizedBox.shrink()
                      : DefaultCornerHandle(handle: handle),
                  sideHandleBuilder: (xtx, handle) => isCapturing
                      ? const SizedBox.shrink()
                      : DefaultSideHandle(handle: handle),
                  rect: rect,
                  clampingRect: Offset.zero & MediaQuery.sizeOf(context),
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
                  widgetController: widgetController,
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
  WidgetsToImageController widgetController;

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

      final imageFile = await convertToImageFile(imageBytes);

      if (imageFile != null) {
        try {
// host image
          final imageUrl = await APIService.hostImage(imageFile);
          logger.i("ImageUrl: $imageUrl");
          // send message on whatsapp
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
        } catch (err) {
          logger.e(err);
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
