import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FireStorageKit {
  static final FireStorageKit _instance = FireStorageKit._internal();
  FireStorageKit._internal();
  factory FireStorageKit() => _instance;

  Future<String> putFile({
    required String directory,
    required String fileName,
    required File file,
    required String contentType,
  }) async {
    final storageRef = FirebaseStorage.instance.ref();
    final fileRef = storageRef.child("$directory/$fileName");
    final result = await fileRef.putFile(
      file,
      SettableMetadata(
        contentType: contentType, // image/jpeg
      ),
    );
    return result.ref.getDownloadURL();
  }
}
