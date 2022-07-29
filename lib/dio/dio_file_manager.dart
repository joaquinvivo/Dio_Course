import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_playground/dio/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FileManager extends StatefulWidget {
  const FileManager({Key? key}) : super(key: key);

  @override
  State<FileManager> createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  final ImagePicker _picker = ImagePicker();
  File? imageFile;

  _getFromGallery() async {
    XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  _uploadImage() async {
    var formData = FormData.fromMap(
      {
        // need to await for this async operation
        "image": await MultipartFile.fromFile(imageFile!.path),
      },
    );
    var response = await DioClient.dio
        .post("http://localhost:3000/upload", data: formData);
    debugPrint(response.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageFile == null
                ? const Icon(Icons.add_photo_alternate)
                : Column(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Image.file(
                          imageFile!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _uploadImage,
                        child: const Text('UPLOAD'),
                      )
                    ],
                  ),
            ElevatedButton(
              onPressed: _getFromGallery,
              child: const Text('PICK FROM GALLERY'),
            ),
          ],
        ),
      ),
    );
  }
}
