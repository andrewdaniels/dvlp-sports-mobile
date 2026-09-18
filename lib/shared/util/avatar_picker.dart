import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../widgets/app_snack_bar.dart';

/// Result of a successful avatar pick — the local file (for preview via
/// `AppAvatar.imageFile`) and the base64-encoded JPEG bytes (what the
/// edge function wants in its request body).
class PickedAvatar {
  const PickedAvatar({required this.file, required this.base64});
  final File file;
  final String base64;
}

/// Open the OS photo library, decode + resize the pick to a 512-square
/// JPEG at q80, and return both the on-disk file (for immediate preview)
/// and its base64 encoding (for the create-profile / update-profile
/// edge fn body).
///
/// Returns null if the user cancels the picker. Returns null + shows a
/// snackbar if decoding or resizing fails — the caller should treat
/// null uniformly (form stays as-is, user can retry).
///
/// Compression runs on a background isolate so the UI stays smooth
/// even for large source images.
Future<PickedAvatar?> pickAvatarFromLibrary(BuildContext context) async {
  final picker = ImagePicker();
  final XFile? picked;
  try {
    picked = await picker.pickImage(source: ImageSource.gallery);
  } catch (e, st) {
    developer.log(
      'pickAvatarFromLibrary: picker.pickImage threw',
      name: 'AvatarPicker',
      error: e,
      stackTrace: st,
    );
    if (context.mounted) {
      AppSnackBar.show(context, message: 'Could not open photo library.');
    }
    return null;
  }
  if (picked == null) return null;

  try {
    final bytes = await picked.readAsBytes();
    if (bytes.isEmpty) {
      throw StateError('Picked file is empty.');
    }
    final jpeg = await compute(_encodeAvatarJpeg, bytes);
    // Write to a temp file so AppAvatar can render via Image.file
    // without holding the raw bytes on the widget tree.
    final tmpDir = Directory.systemTemp;
    final tmpFile = await File(
      '${tmpDir.path}/avatar_${DateTime.now().microsecondsSinceEpoch}.jpg',
    ).create();
    await tmpFile.writeAsBytes(jpeg, flush: true);
    return PickedAvatar(file: tmpFile, base64: base64Encode(jpeg));
  } catch (e, st) {
    developer.log(
      'pickAvatarFromLibrary: could not process picked image',
      name: 'AvatarPicker',
      error: e,
      stackTrace: st,
    );
    if (context.mounted) {
      AppSnackBar.show(context, message: 'Could not process that photo. Try another.');
    }
    return null;
  }
}

/// Runs on a background isolate — decode source bytes, resize to fit a
/// 512×512 square (cover), re-encode as JPEG q80. Isolate entry points
/// must be top-level.
Uint8List _encodeAvatarJpeg(Uint8List sourceBytes) {
  final decoded = img.decodeImage(sourceBytes);
  if (decoded == null) {
    throw StateError('Unsupported image format.');
  }
  // Cover-fit into 512² — shorter side hits 512, longer side is
  // center-cropped. `img.copyResizeCropSquare` does exactly this in
  // one pass without an intermediate buffer.
  final resized = img.copyResizeCropSquare(
    decoded,
    size: 512,
    interpolation: img.Interpolation.average,
    antialias: true,
  );
  return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
}
