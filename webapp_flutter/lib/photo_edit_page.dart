// photo_edit_page.dart

import 'package:flutter/material.dart';
import 'photo.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:path_provider/path_provider.dart';

class PhotoEditPage extends StatefulWidget {
  final Photo photo;
  const PhotoEditPage({super.key, required this.photo});

  @override
  PhotoEditPageState createState() => PhotoEditPageState();
}

class PhotoEditPageState extends State<PhotoEditPage> {
  bool _isProcessing = false; // 로딩 상태 관리 변수 추가
  Uint8List? _editedImageBytes; // 편집된 이미지의 바이트 데이터

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.photo.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Navigator.of(context).pop(widget.photo.id); // 삭제 버튼 클릭 시 사진 ID 반환
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (_editedImageBytes != null)
              Expanded(
                flex: 4,
                child: Image.memory(_editedImageBytes!),
              )
            else
              Expanded(
                flex: 4,
                child: loadImage(widget.photo),
              ),
            const SizedBox(height: 20),
            Text(
              widget.photo.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text('Remove Background',
                  style: TextStyle(color: Colors.white)),
              onPressed: _isProcessing ? null : _removeBackground,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 24),
            if (_isProcessing) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Future<void> _removeBackground() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final file = File(widget.photo.url);
      if (!file.existsSync()) {
        debugPrint(
            'Error: Image file does not exist at path: ${widget.photo.url}');
        return;
      }
      Uint8List imageBytes = await file.readAsBytes();

      // Send the image to the FastAPI server
      var uri =
          // @TODO: Update the ngrok URL with your own URL
          // Uri.parse('https://YOUR_NGROK_URL_HERE/remove_bg');
          Uri.parse('https://13e3-220-117-157-240.ngrok-free.app/remove_bg');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile.fromBytes('file', imageBytes,
            filename: 'image.jpg', contentType: MediaType('image', 'jpeg')));

      debugPrint('Sending image to server for background removal...');
      var response = await request.send();

      if (response.statusCode == 200) {
        // Read the response bytes
        final responseBytes = await response.stream.toBytes();
        setState(() {
          _editedImageBytes = responseBytes;
        });

        // Optionally, save the edited image to a file
        final directory = await getApplicationDocumentsDirectory();
        final editedImagePath =
            '${directory.path}/edited_${widget.photo.id}.png';
        File editedImageFile = File(editedImagePath);
        await editedImageFile.writeAsBytes(responseBytes);
        debugPrint('Edited image saved at $editedImagePath');
      } else {
        debugPrint(
            'Failed to remove background. Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error during background removal: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}
