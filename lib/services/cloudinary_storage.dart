import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // 1. Apni Cloudinary details yahan replace karein
  static const String _cloudName = "dutsuqswv";
  static const String _uploadPreset = "heaz0p48"; 

  /// Image upload karega aur uploaded image ka secure URL return karega
  static Future<String?> uploadImage({
    required Uint8List bytes,
    String? fileName,
    String folderName = "announcements",
  }) async {
    try {
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$_cloudName/image/upload",
      );

      final request = http.MultipartRequest("POST", uri)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['folder'] = folderName
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: fileName ??
                "upload_${DateTime.now().millisecondsSinceEpoch}.jpg",
          ),
        );

      final http.StreamedResponse streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? secureUrl = data['secure_url'];
        return secureUrl;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        print("Cloudinary Error: ${errorData['error']?['message'] ?? response.body}");
        return null;
      }
    } catch (e) {
      print("Cloudinary Exception: $e");
      return null;
    }
  }
}