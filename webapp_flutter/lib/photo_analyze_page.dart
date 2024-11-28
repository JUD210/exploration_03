import 'package:flutter/material.dart';
import '../photo.dart';
import 'image_analyzer.dart'; // 이미지 분석 모듈 가져오기
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // API 키를 위한 dotenv 가져오기

class PhotoAnalyzePage extends StatefulWidget {
  final Photo photo;
  const PhotoAnalyzePage({super.key, required this.photo});

  @override
  PhotoAnalyzePageState createState() => PhotoAnalyzePageState();
}

class PhotoAnalyzePageState extends State<PhotoAnalyzePage> {
  String _analyzedText = "";
  bool _isAnalyzing = false; // 로딩 상태 관리 변수 추가

  @override
  void initState() {
    super.initState();
    _initializeAPIKey(); // 상태 초기화 시 API 키 초기화
  }

  Future<void> _initializeAPIKey() async {
    await dotenv.load(fileName: ".env");
  }

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
              icon: const Icon(Icons.analytics, color: Colors.white),
              label:
                  const Text('이미지 분석', style: TextStyle(color: Colors.white)),
              onPressed: _isAnalyzing ? null : _analyzeImage, // 분석 중이면 버튼 비활성화
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 24),
            if (_isAnalyzing) // 로딩 중일 때 로딩 인디케이터 표시
              const CircularProgressIndicator(),
            const SizedBox(height: 16),
            if (_analyzedText.isNotEmpty)
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: double.infinity),
                      child: SelectableText(
                        _analyzedText,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.teal[900],
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeImage() async {
    // 현재 보고 있는 이미지를 가져와 분석합니다.
    setState(() {
      _isAnalyzing = true;
      _analyzedText = "";
    });

    try {
      final file = File(widget.photo.url);
      if (!file.existsSync()) {
        debugPrint('오류: 이미지 파일이 경로에 존재하지 않습니다: ${widget.photo.url}');
        return;
      }
      Uint8List imageBytes = await file.readAsBytes();
      String apiKey = dotenv.env['API_KEY'] ?? '';

      if (apiKey.isEmpty) {
        debugPrint('API 키가 없습니다. .env 파일을 확인하세요.');
        return;
      }

      final String result = await analyzeImage(context, imageBytes, apiKey);

      setState(() {
        _analyzedText = result;
      });
    } catch (e) {
      debugPrint('이미지를 가져오는 중 오류 발생: $e. 이미지 URL이 올바르고 접근 가능한지 확인하세요.');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }
}
