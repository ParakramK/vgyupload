import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'package:http/http.dart' as http;

const String uploadURL = 'https://vgy.me/upload';

Future<String?> uploadImage(String filepath, String apiKey) async {
  const int maxFileSize = 20 * 1024 * 1024;
  const List<String> allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif'];

  if (!File(filepath).existsSync()) {
    print('Error: $filepath is not a valid file path');
    return null;
  }
  if (File(filepath).lengthSync() > maxFileSize) {
    print(
        'Error: $filepath exceeds the maximum file size of $maxFileSize bytes');
    return null;
  }
  final fileName = p.basename(filepath);
  final fileExtension = p.extension(fileName).toLowerCase();
  if (!allowedExtensions.contains(fileExtension)) {
    print('Error: $filepath has an invalid file extension');
    return null;
  }
  var request = http.MultipartRequest('POST', Uri.parse(uploadURL));
  request.files.add(await http.MultipartFile.fromPath('file', filepath));
  request.fields['userkey'] = apiKey;

  try {
    var response = await request.send();

    // print('Response Status Code: ${response.statusCode}');
    // print('Response Reason Phrase: ${response.reasonPhrase}');

    if (response.statusCode == 200) {
      var resBody = await response.stream.bytesToString();
      var data = json.decode(resBody);
      // print(data);

      if (data['error'] == true) {
        print('Error: ${data['message']}');
        return null;
      }

      String imageUrl = data['image'];
      return imageUrl;
    } else {
      print('Error: HTTP ${response.statusCode} -- ${response.reasonPhrase}');
      return null;
    }
  } catch (e) {
    print('Error uploading image: $e');
    return null;
  }
}

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print("Usage: vgyupload APIKEY PATH [PATH ...]");
    return;
  }
  if (arguments.length < 2) {
    print("Usage: vgyupload APIKEY PATH [PATH ...]");
    return;
  }
  String? apiKey = arguments[0];
  if (apiKey.isEmpty) {
    print('api key not found');
    exit(1);
  }
  for (int i = 1; i < arguments.length; i++) {
    String? imageUrl = await uploadImage(arguments[i], apiKey);
    if (imageUrl != null) {
      print(imageUrl);
    } else {
      print('Failed to upload image.');
    }
  }
}
