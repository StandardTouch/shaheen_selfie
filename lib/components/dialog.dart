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

  // NOTE: fixed common env var typo + added logs
  String? get cloudApiKey   => dotenv.env["CLOUDINARY_API_KEY"];
  String? get cloudApiSecret=> dotenv.env["CLOUDINARY_API_SECRET"];
  String? get cloudName     => (dotenv.env["CLOUDINARY_CLOUD_NAME"] ?? dotenv.env["CLOUDINAME"]);

  @override
  void initState() {
    super.initState();
    localSelectedMessage = widget.selectedMessage;

    // ---- Debug: env + state ----
    logger.t("[Dialog:initState] selectedMessage='${widget.selectedMessage}'");
    logger.t("[Dialog:initState] Env keys present? "
        "API_KEY=${cloudApiKey?.isNotEmpty == true}, "
        "API_SECRET=${cloudApiSecret?.isNotEmpty == true}, "
        "CLOUD_NAME=${cloudName?.isNotEmpty == true}");
  }

  String generateUniqueString() {
    final Random random = Random();
    final randomString = List.generate(10, (_) => random.nextInt(256).toRadixString(16)).join();
    final timestamp = DateFormat('yyyyMMddHHmmssSSS').format(DateTime.now());
    return '$timestamp-$randomString';
  }

  Future<void> sharePicture() async {
    final sw = Stopwatch()..start();
    logger.i("[sharePicture] Started");

    // Validate env
    if (cloudApiKey == null || cloudApiSecret == null || cloudName == null) {
      logger.e("[sharePicture] Missing Cloudinary config. "
          "API_KEY? ${cloudApiKey != null}, SECRET? ${cloudApiSecret != null}, NAME? ${cloudName != null}");
      if (!mounted) return;
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(message: "Cloudinary config missing. Check .env keys."),
      );
      return;
    }

    // Validate form
    final isValid = formKey.currentState?.validate() ?? false;
    logger.t("[sharePicture] form valid? $isValid");
    if (!isValid) {
      return;
    }
    formKey.currentState!.save();
    logger.t("[sharePicture] phoneNumber='$phoneNumber'");
    logger.t("[sharePicture] message='${localSelectedMessage.replaceAll('\n', '\\n')}'");

    setState(() => isLoading = true);

    try {
      // Capture
      logger.t("[sharePicture] Capturing screenshot…");
      final imageBytes = await capturePng();
      logger.t("[sharePicture] Capture size=${imageBytes.length} bytes");

      // File write
      logger.t("[sharePicture] Writing temp file…");
      final imageFile = await convertToImageFile(imageBytes);
      if (imageFile == null) {
        throw Exception("Image file creation failed");
      }
      logger.t("[sharePicture] Temp file at: ${imageFile.path} (size=${await imageFile.length()} bytes)");

      // Upload
      logger.t("[sharePicture] Creating Cloudinary client…");
      final cloudinary = Cloudinary.full(
        apiKey: cloudApiKey!,
        apiSecret: cloudApiSecret!,
        cloudName: cloudName!,
      );

      final uniqueName = generateUniqueString();
      logger.t("[sharePicture] Uploading to Cloudinary… folder=shaheen_students name=$uniqueName");
      final uploadSw = Stopwatch()..start();
      final uploadResponse = await cloudinary.uploadResource(
        CloudinaryUploadResource(
          filePath: imageFile.path,
          // (sync read is ok for small files; async is nicer—use await imageFile.readAsBytes() if you prefer)
          fileBytes: imageFile.readAsBytesSync(),
          resourceType: CloudinaryResourceType.image,
          folder: "shaheen_students",
          fileName: uniqueName,
        ),
      );
      uploadSw.stop();
      final imageUrl = uploadResponse.secureUrl;
      logger.i("[sharePicture] Upload done in ${uploadSw.elapsedMilliseconds} ms, url=$imageUrl");

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception("Cloudinary returned empty secureUrl");
      }

      // Send WhatsApp
      logger.t("[sharePicture] Sending WhatsApp via APIService…");
      final sendSw = Stopwatch()..start();
      final isSent = await APIService.sendWhatsappMessage(
        mobileNo: phoneNumber,
        imageUrl: imageUrl,
        message: localSelectedMessage,
      );
      sendSw.stop();
      logger.i("[sharePicture] WhatsApp send result=$isSent in ${sendSw.elapsedMilliseconds} ms");

      if (!mounted) return;
      showTopSnackBar(
        Overlay.of(context),
        isSent
            ? const CustomSnackBar.success(message: "Message Sent")
            : const CustomSnackBar.error(message: "An Error Occurred while sending"),
      );
    } catch (err, st) {
      logger.e("[sharePicture] FAILED: $err", stackTrace: st);
      if (!mounted) return;
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(message: "An Error Occurred"),
      );
    } finally {
      sw.stop();
      logger.i("[sharePicture] Finished in ${sw.elapsedMilliseconds} ms");
      if (mounted) setState(() => isLoading = false);

      // Navigate home after attempt (your original behavior). If you only want on success,
      // move these lines inside the success branch above.
      if (!mounted) return;
      context.pop();
      context.go("/home");
    }
  }

  Future<Uint8List> capturePng() async {
    logger.t("[capturePng] Requesting screenshot from controller…");
    final bytes = await widget.widgetController.capture();
    if (bytes == null) {
      logger.e("[capturePng] Controller returned null bytes");
      throw Exception("Screenshot capture returned null");
    }
    logger.t("[capturePng] Bytes captured: ${bytes.length}");
    return bytes;
  }

  Future<File?> convertToImageFile(Uint8List pngBytes) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/shaheen_$ts.png');
      await file.writeAsBytes(pngBytes, flush: true);
      logger.t("[convertToImageFile] Wrote file: ${file.path}");
      return file;
    } catch (e, st) {
      logger.e("[convertToImageFile] Exception: $e", stackTrace: st);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      logger.t("[Dialog:build] isLoading=$isLoading mounted=$mounted");
      return AlertDialog(
        scrollable: true,
        title: const Text("Enter Parent's Phone Number"),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // Message dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: DropdownButtonFormField<String>(
                    value: localSelectedMessage,
                    onChanged: (newMessage) {
                      logger.t("[Dropdown] onChanged -> ${newMessage?.substring(0, (newMessage.length > 24 ? 24 : newMessage!.length))}...");
                      if (newMessage == null) return;
                      setState(() => localSelectedMessage = newMessage);
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    isExpanded: true,
                    menuMaxHeight: 200,
                  ),
                ),

                // Phone field
                TextFormField(
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    label: Text("Mobile number"),
                    prefixText: "+91",
                  ),
                  validator: (value) {
                    final v = (value ?? "").trim();
                    final ok = RegExp(r'^[6-9]\d{9}$').hasMatch(v);
                    logger.t("[Validator] phone='$v' valid=$ok");
                    if (!ok) return "Please enter a valid Number";
                    return null;
                  },
                  onSaved: (newVal) {
                    phoneNumber = (newVal ?? "").trim();
                    logger.t("[Form:onSaved] phoneNumber='$phoneNumber'");
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
            
            // IMPORTANT: actually call the function
            onPressed: isLoading ? null : () async {
              logger.t("[Button] Send Message tapped");
              await Future.delayed(const Duration(milliseconds: 200)); // let it settle

    await sharePicture(); // <-- call the function
            },
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text("Send Message"),
          ),
        ],
      );
    });
  }
}
