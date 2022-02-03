import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File videoFile) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      return ref.putFile(videoFile);
    } on FirebaseException catch (e) {
      throw (e);
    }
  }
}
