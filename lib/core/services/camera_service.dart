import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _picker = ImagePicker();

  Future<bool> checkCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    
    return status.isGranted;
  }

  Future<File?> takePicture() async {
    try {
      // Check camera permission
      bool hasPermission = await checkCameraPermission();
      if (!hasPermission) {
        throw Exception('Camera permission denied');
      }

      // Take picture
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) return null;

      // Save image to app directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(appDir.path, 'images', fileName);
      
      // Create images directory if it doesn't exist
      final Directory imagesDir = Directory(path.join(appDir.path, 'images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Copy image to app directory
      final File savedImage = await File(image.path).copy(filePath);
      
      return savedImage;
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) return null;

      // Save image to app directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(appDir.path, 'images', fileName);
      
      // Create images directory if it doesn't exist
      final Directory imagesDir = Directory(path.join(appDir.path, 'images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Copy image to app directory
      final File savedImage = await File(image.path).copy(filePath);
      
      return savedImage;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<bool> deleteImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}
