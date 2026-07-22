import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../core/secrets.dart';

class CloudinaryService {
  final CloudinaryPublic cloudinary = CloudinaryPublic(
    AppSecrets.cloudinaryCloudName,
    AppSecrets.cloudinaryUploadPreset,
    cache: false,
  );

  Future<String?> uploadImage(File file, {String folder = 'general'}) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Cloudinary Upload Error: $e');
      return null;
    }
  }
}
