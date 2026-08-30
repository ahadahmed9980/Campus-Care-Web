import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = "dutsquswv";
  static const String _uploadPreset = "heaz0p48";

  static Future<String?> uploadImage({
    required Uint8List bytes,
    String? fileName,
    String folderName = "announcements",
  }) async {
    try {
      print("========== CLOUDINARY UPLOAD START ==========");
      print("Cloud Name: $_cloudName");
      print("Upload Preset: $_uploadPreset");
      print("File Name: $fileName");
      print("Folder: $folderName");
      print("File Size: ${bytes.length} bytes");

      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$_cloudName/image/upload",
      );

      print("Cloudinary URL: $uri");

      final request = http.MultipartRequest("POST", uri);

      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folderName;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename:
              fileName ?? "upload_${DateTime.now().millisecondsSinceEpoch}.jpg",
        ),
      );

      print("Sending image to Cloudinary...");

      final streamedResponse = await request.send();

      print("Streamed Response Status: ${streamedResponse.statusCode}");

      final response = await http.Response.fromStream(streamedResponse);

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final String? secureUrl = data['secure_url'];

        print("Upload Successful");
        print("Public ID: ${data['public_id']}");
        print("Secure URL: $secureUrl");

        if (secureUrl == null || secureUrl.isEmpty) {
          print("ERROR: secure_url is null or empty");
          return null;
        }

        print("========== CLOUDINARY UPLOAD END ==========");

        return secureUrl;
      }

      print("Cloudinary Upload Failed");

      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);

        print(
          "Cloudinary Error: "
          "${errorData['error']?['message'] ?? response.body}",
        );
      } catch (e) {
        print("Error parsing Cloudinary error: $e");
        print("Raw Response: ${response.body}");
      }

      print("========== CLOUDINARY UPLOAD END ==========");

      return null;
    } catch (e, stackTrace) {
      print("Cloudinary Exception: $e");
      print("Stack Trace: $stackTrace");
      print("========== CLOUDINARY UPLOAD END ==========");

      return null;
    }
  }
}
