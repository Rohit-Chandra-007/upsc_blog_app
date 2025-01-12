import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:civilshots/core/error/exception.dart';

Future<File?> pickImageFromGallery() async {
  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  } on PlatformException catch (e) {
    throw UnknownException(message: e.toString());
  }
}

Future<File?> pickImageFromCamera() async {
  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  } on PlatformException catch (e) {
    throw UnknownException(message: e.toString());
  }
}
