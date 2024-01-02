import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as p;
// import 'dart:convert';
// import 'package:http/http.dart' as http;

Future<String?> uploadImage(String filepath, String apiKey,
    {String url = 'https://vgy.me/upload'}) async {
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
}

void main(List<String> arguments) {
  if (arguments.length < 2) {
    print("Usage: dart vgyupload API_KEY PATH [PATH ...]");
    return;
  }
  final apikey = arguments[0];
  final paths = arguments.sublist(1);
}
