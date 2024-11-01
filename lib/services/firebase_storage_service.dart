import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Method to upload an image to Firebase Storage and get its download URL
  Future<String> uploadImageToStorage(File image) async {
    try {
      // Generate a unique file name using the file name and current timestamp
      String fileName = basename(image.path);
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fullFileName = "$fileName-$timestamp";

      // Create a reference to the location where the image will be stored
      Reference storageRef =
          _storage.ref().child('uploads/images/$fullFileName');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(image);

      // Wait for the upload to complete and get the download URL
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl; // Return the download URL
    } catch (e) {
      print("Error uploading image: $e");
      throw Exception("Failed to upload image to Firebase Storage");
    }
  }
}