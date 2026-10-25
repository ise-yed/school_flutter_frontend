// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';

// class ImageHandler {
//   XFile? pickedFile;

//   Future<void> pickAndCompressImage({
//     required ImageSource source,
//     int quality = 60,
//     int maxSizeInKB = 500,
//   }) async {
//     try {
//       final picked = await ImagePicker().pickImage(source: source);
//       if (picked == null) return;

//       XFile? compressedFile;

//       if (kIsWeb) {
//         final bytes = await picked.readAsBytes();
//         final compressedBytes = await FlutterImageCompress.compressWithList(
//           bytes,
//           quality: quality,
//         );
//         compressedFile = XFile.fromData(
//           compressedBytes,
//           name: picked.name,
//           mimeType: 'image/jpeg',
//         );
//       } else {
//         compressedFile = await compressImage(File(picked.path), quality);
//       }
//       // ! if not compressed
//       if (compressedFile == null) return;

//       pickedFile = compressedFile;
//     } catch (e) {}
//   }

//   Future<XFile?> compressImage(File file, int quality) async {
//     final tempDir = await getTemporaryDirectory();
//     final targetPath = p.join(
//       tempDir.path,
//       '${DateTime.now().millisecondsSinceEpoch}.jpg',
//     );

//     final result = await FlutterImageCompress.compressAndGetFile(
//       file.absolute.path,
//       targetPath,
//       quality: quality,
//     );

//     if (result == null) return null;
//     return XFile(result.path);
//   }

//   dynamic get getImage => pickedFile;
// }
