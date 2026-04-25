import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryException implements Exception {
  final String message;
  const CloudinaryException([this.message = 'Error al subir la imagen']);
}

class CloudinaryService {
  static const String _cloudName = 'dmqwxxrmt';
  final String _uploadPreset;

  const CloudinaryService({required String uploadPreset})
      : _uploadPreset = uploadPreset;

  // Uses XFile (cross-platform: works on mobile AND web)
  Future<String> uploadProfilePhoto(XFile imageFile) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final bytes = await imageFile.readAsBytes();

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = 'flashmind/avatars'
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name,
      ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final error = (body['error'] as Map<String, dynamic>?)?['message']
              as String? ??
          'Error al subir la imagen';
      throw CloudinaryException(error);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final secureUrl = json['secure_url'] as String?;
    if (secureUrl == null) {
      throw const CloudinaryException('No se recibió URL de Cloudinary');
    }
    return secureUrl;
  }
}
