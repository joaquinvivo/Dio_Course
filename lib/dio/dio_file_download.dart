import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_playground/dio/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class FileDownload extends StatefulWidget {
  const FileDownload({Key? key}) : super(key: key);

  @override
  State<FileDownload> createState() => _FileDownloadState();
}

class _FileDownloadState extends State<FileDownload> {
  final String _downloadPath =
      'https://logowik.com/content/uploads/images/flutter5786.jpg';
  // 'https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg';
  File? _imageFile;
  late String _destPath;
  late CancelToken _cancelToken;
  bool _downloading = false;
  double _downloadRatio = 0.0;
  String _downloadIndicator = '0.00%';

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory()
        .then((tempDir) => {_destPath = '${tempDir.path}/file.dmg'});
  }

  _downloadFile(
    String downloadPath,
    String destPath,
  ) async {
    _cancelToken = CancelToken();
    _downloading = true;
    try {
      await DioClient.dio
          .download(downloadPath, destPath, cancelToken: _cancelToken,
              onReceiveProgress: (int received, int total) {
        if (total != -1) {
          if (!_cancelToken.isCancelled) {
            setState(() {
              _downloadRatio = received / total;
              if (_downloadRatio == 1) {
                _downloading = false;
                _imageFile = File(_destPath);
              }
              _downloadIndicator =
                  '${(_downloadRatio * 100).toStringAsFixed(2)}%';
            });
          }
        }
      });
    } on DioError catch (e) {
      if (CancelToken.isCancel(e)) {
        debugPrint('Request cancelled! ${e.message}');
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  void _cancelDownload() {
    if (_downloadRatio < 1.0) {
      _cancelToken.cancel();
      _downloading = false;
      setState(() {
        _downloadRatio = 0;
        _downloadIndicator = '0.00%';
      });
    }
  }

  void _deleteFile(String destPath) {
    try {
      File downloadedFile = File(destPath);
      if (downloadedFile.existsSync()) {
        downloadedFile.delete();
        setState(() {
          _downloading = false;
          _imageFile = null;
          _downloadRatio = 0;
          _downloadIndicator = '0.00%';
        });
        debugPrint('Delete file successfull');
      } else {
        debugPrint('File doesn\'t exist');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_imageFile != null)
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _downloadFile(
                      _downloadPath,
                      _destPath,
                    ),
                    child: const Text('Download'),
                  ),
                  TextButton(
                    onPressed: _cancelDownload,
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(primary: Colors.red),
                    onPressed:
                        _downloading ? null : () => _deleteFile(_destPath),
                    child: const Text('Delete'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: LinearPercentIndicator(
                      percent: _downloadRatio,
                      progressColor: Colors.blue,
                    ),
                  ),
                  Text(_downloadIndicator),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
