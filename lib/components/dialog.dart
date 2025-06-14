import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shaheen_selfie/utils/config/logger.dart';
import 'package:shaheen_selfie/utils/messages.dart';
import 'package:shaheen_selfie/utils/services/api_service.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

final formKey = GlobalKey<FormState>();

class ShaheenAlertDialog extends StatefulWidget {
  ShaheenAlertDialog({
    super.key,
    required this.widgetController,
    required this.selectedMessage,
    required this.onMessageChanged,
  });

  final ScreenshotController widgetController;
  final String selectedMessage;
  final ValueChanged<String?> onMessageChanged;

  @override
  _ShaheenAlertDialogState createState() => _ShaheenAlertDialogState();
}

class _ShaheenAlertDialogState extends State<ShaheenAlertDialog> {
  bool isLoading = false;
  String phoneNumber = "";
  late String localSelectedMessage;
  final cloudApiKey = dotenv.env["CLOUDINARY_API_KEY"];
    final cloudApiSecret = dotenv.env["CLOUDINARY_API_SECRET"];
  final cloudName = dotenv.env["CLOUDINAME"];


  @override
  void initState() {
    super.initState();
    localSelectedMessage = widget.selectedMessage;
  }

  // Method to generate a unique string
  String generateUniqueString() {
    final Random random = Random();
    String randomString = List.generate(10, (_) => random.nextInt(256).toRadixString(16)).join();
    String timestamp = DateFormat('yyyyMMddHHmmssSSS').format(DateTime.now());
    return '$timestamp-$randomString';
  }

  void sharePicture() async {
    final cloudinary = Cloudinary.full(
      apiKey: cloudApiKey!,
      apiSecret: cloudApiSecret!,
      cloudName: cloudName!,
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

          print("Sending message: $localSelectedMessage");

          final isSent = await APIService.sendWhatsappMessage(
            mobileNo: phoneNumber,
            imageUrl: imageUrl!,
            message: localSelectedMessage,
          );

          if (!context.mounted) return;
          showTopSnackBar(
            Overlay.of(context),
            isSent
                ? const CustomSnackBar.success(message: "Message Sent")
                : const CustomSnackBar.error(message: "An Error Occurred"),
          );
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
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        scrollable: true,
        title: const Text("Enter Parent's Phone Number"),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: DropdownButtonFormField<String>(
  value: localSelectedMessage,
  onChanged: (newMessage) {
    if (newMessage == null) return;
    setState(() {
      localSelectedMessage = newMessage;
    });
    widget.onMessageChanged(newMessage);
  },
  items: DummyMessages.messages.entries.map((entry) {
    return DropdownMenuItem<String>(
      value: entry.value,
      child: Text(entry.key),
    );
  }).toList(),
  decoration: InputDecoration(
    labelText: "Select Message",
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  isExpanded: true,
  menuMaxHeight: 200,
),
 ),
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
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: isLoading ? null : () => context.pop(),
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
    });
  }
}
