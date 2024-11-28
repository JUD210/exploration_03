import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({super.key, required this.camera});

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture; // 컨트롤러 초기화 Future 추가

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing TakePictureScreen...'); // Debugging log
    _initializeCamera(); // 카메라 초기화 함수 호출
  }

  /// 카메라를 초기화하는 함수
  void _initializeCamera() {
    _controller = CameraController(
      widget.camera, // 사용할 카메라 지정
      ResolutionPreset.max, // 최대 해상도로 설정
      enableAudio: false, // 오디오 비활성화
    );

    _initializeControllerFuture = _controller.initialize(); // 카메라 초기화 Future 설정
    _initializeControllerFuture.then((_) {
      if (mounted) {
        setState(() {
          debugPrint('Camera controller initialized.'); // Debugging log
        });
      }
    }).catchError((e) {
      debugPrint('Error initializing camera: $e'); // Debugging log
    });
  }

  /// 사진을 찍는 함수 정의
  Future<void> _takePicture() async {
    if (!_controller.value.isInitialized) {
      debugPrint('Camera is not initialized.'); // Debugging log
      return;
    }
    try {
      final XFile file = await _controller.takePicture();
      debugPrint('Picture taken: ${file.path}'); // Debugging log

      /// 사진을 저장할 경로 지정
      Directory directory = Directory('storage/emulated/0/DCIM/MyImages');
      await Directory(directory.path).create(recursive: true);
      debugPrint('Directory created: ${directory.path}'); // Debugging log

      /// 지정한 경로에 사진 저장
      final savedImage =
          await File(file.path).copy('${directory.path}/${file.name}');
      debugPrint('Image saved to: ${savedImage.path}'); // Debugging log
      if (mounted) {
        Navigator.of(context).pop(savedImage.path); // 저장한 사진 경로 반환하며 페이지 종료
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    debugPrint('Camera controller disposed.'); // Debugging log
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture, // 초기화 Future를 사용하여 카메라 준비 상태 확인
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (_controller.value.isInitialized) {
            // 카메라 초기화 완료 시 프리뷰 표시
            debugPrint('Camera is ready. Displaying preview.'); // Debugging log
            return Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(_controller), // 카메라 프리뷰 표시
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: GestureDetector(
                        /// 사진 촬영 버튼 클릭 이벤트 정의
                        onTap: () {
                          debugPrint(
                              'Take picture button pressed.'); // Debugging log
                          _takePicture(); // 사진 촬영 함수 호출
                        },
                        child: const Icon(
                          Icons.camera_enhance,
                          size: 70,
                          color: Colors.white,
                        ),
                      )),
                ),
              ],
            );
          } else {
            return const Center(child: Text('Camera initialization failed.'));
          }
        } else {
          // 카메라 초기화 중일 때 로딩 인디케이터 표시
          debugPrint('Camera is initializing...'); // Debugging log
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
