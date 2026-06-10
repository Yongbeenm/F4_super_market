import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

/// Firebase Storage Service
/// Handles file uploads and downloads
/// Note: Currently using web URLs for images, but this service is available for future use
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==================== Upload Operations ====================

  /// Upload a file to Firebase Storage
  Future<String> uploadFile(
    File file,
    String folder, {
    String? fileName,
    Function(double)? onProgress,
  }) async {
    try {
      // Generate file name if not provided
      final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final ref = _storage.ref().child('$folder/$name');

      // Upload file
      final uploadTask = ref.putFile(file);

      // Listen to progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      await uploadTask;

      // Get download URL
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to upload file: $e';
    }
  }

  /// Upload multiple files
  Future<List<String>> uploadMultipleFiles(
    List<File> files,
    String folder, {
    Function(int, double)? onProgress,
  }) async {
    try {
      final urls = <String>[];

      for (var i = 0; i < files.length; i++) {
        final url = await uploadFile(
          files[i],
          folder,
          onProgress: (progress) {
            onProgress?.call(i, progress);
          },
        );
        urls.add(url);
      }

      return urls;
    } catch (e) {
      throw 'Failed to upload multiple files: $e';
    }
  }

  /// Upload image with compression (requires flutter_image_compress package)
  Future<String> uploadImage(
    File file,
    String folder, {
    String? fileName,
    int quality = 85,
    Function(double)? onProgress,
  }) async {
    try {
      // For now, just upload without compression
      // You can add flutter_image_compress package and implement compression here
      return await uploadFile(file, folder, fileName: fileName, onProgress: onProgress);
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  // ==================== Download Operations ====================

  /// Get download URL for a file
  Future<String> getDownloadURL(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to get download URL: $e';
    }
  }

  /// Download file to local storage
  Future<File> downloadFile(String filePath, String localPath) async {
    try {
      final ref = _storage.ref().child(filePath);
      final file = File(localPath);
      await ref.writeToFile(file);
      return file;
    } catch (e) {
      throw 'Failed to download file: $e';
    }
  }

  /// Get file metadata
  Future<FullMetadata> getMetadata(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      return await ref.getMetadata();
    } catch (e) {
      throw 'Failed to get metadata: $e';
    }
  }

  // ==================== Delete Operations ====================

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      await ref.delete();
    } catch (e) {
      throw 'Failed to delete file: $e';
    }
  }

  /// Delete a file by its download URL
  Future<void> deleteFileByURL(String downloadURL) async {
    try {
      final ref = _storage.refFromURL(downloadURL);
      await ref.delete();
    } catch (e) {
      throw 'Failed to delete file by URL: $e';
    }
  }

  /// Delete multiple files
  Future<void> deleteMultipleFiles(List<String> filePaths) async {
    try {
      for (final filePath in filePaths) {
        await deleteFile(filePath);
      }
    } catch (e) {
      throw 'Failed to delete multiple files: $e';
    }
  }

  // ==================== List Operations ====================

  /// List all files in a folder
  Future<List<Reference>> listFiles(String folder) async {
    try {
      final ref = _storage.ref().child(folder);
      final result = await ref.listAll();
      return result.items;
    } catch (e) {
      throw 'Failed to list files: $e';
    }
  }

  /// List all folders in a path
  Future<List<Reference>> listFolders(String folder) async {
    try {
      final ref = _storage.ref().child(folder);
      final result = await ref.listAll();
      return result.prefixes;
    } catch (e) {
      throw 'Failed to list folders: $e';
    }
  }

  // ==================== Utility Methods ====================

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(String filePath) async {
    try {
      final metadata = await getMetadata(filePath);
      return metadata.size ?? 0;
    } catch (e) {
      throw 'Failed to get file size: $e';
    }
  }

  /// Extract file path from download URL
  String getFilePathFromURL(String downloadURL) {
    try {
      final ref = _storage.refFromURL(downloadURL);
      return ref.fullPath;
    } catch (e) {
      throw 'Failed to extract file path from URL: $e';
    }
  }

  /// Get storage reference
  Reference getReference(String filePath) {
    return _storage.ref().child(filePath);
  }

  /// Get root reference
  Reference getRootReference() {
    return _storage.ref();
  }
}
