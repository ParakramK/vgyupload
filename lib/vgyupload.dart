import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiKey = String.fromEnvironment('VGYAPI');
const String uploadURL = 'https://vgy.me/upload';

Future<String?> uploadImage(String filepath) async {
  const maxFileSize = 20 * 1024 * 1024;
  const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif'];
  if (!File(filepath).absolute.existsSync()) {
    print('Error: $filepath is not an absolute path');
    return null;
  }
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
    if (response.statusCode == 200) {
      var resBody = await response.stream.bytesToString();
      var data = json.decode(resBody);
      if (data['error'] != null) {
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
    print('Error: $e');
    return null;
  }
}

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print("Usage: dart vgyupload API_KEY PATH [PATH ...]");
    return;
  }
  if (apiKey.isEmpty) {
    print('api key not found');
    exit(1);
  }
  for (int i = 0; i < arguments.length; i++) {
    print('Argument $i: ${arguments[i]}');
  }
}
