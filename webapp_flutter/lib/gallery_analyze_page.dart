// gallery_analyze_page.dart

import 'package:flutter/material.dart';
import 'photo.dart';
import 'photo_analyze_page.dart';
import 'camera.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart'; // For image picking

class GalleryAnalyzePage extends StatefulWidget {
  final CameraDescription camera;

  const GalleryAnalyzePage({super.key, required this.camera});

  @override
  State<GalleryAnalyzePage> createState() => _GalleryAnalyzePageState();
}

class _GalleryAnalyzePageState extends State<GalleryAnalyzePage> {
  final List<Photo> _photos = []; // 사진 리스트를 관리하는 변수
  bool _isDeleting = false; // 삭제 모드인지 여부를 관리하는 변수
  final Set<int> _selectedPhotos = {}; // 삭제 모드에서 선택된 사진의 ID를 저장하는 집합
  int _nextPhotoId = 1; // 새로운 사진의 ID를 관리하는 변수

  final ImagePicker _picker = ImagePicker(); // Image picker instance

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing GalleryAnalyzePage...'); // Debugging log
    _loadPhotos(); // 로컬 저장소에서 저장된 사진들을 불러옵니다.
  }

  /// 로컬 저장소에서 사진 목록을 불러오는 함수
  Future<void> _loadPhotos() async {
    debugPrint('Loading photos from local storage...'); // Debugging log
    final prefs = await SharedPreferences.getInstance();
    final String? photosJson = prefs.getString('photos');
    if (photosJson != null) {
      final List<dynamic> photosList = jsonDecode(photosJson);
      setState(() {
        _photos.addAll(photosList.map((e) => Photo.fromJson(e)).toList());
        _nextPhotoId = _photos.isNotEmpty
            ? _photos.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1
            : 1; // 가장 큰 ID를 찾고, 다음 ID를 설정
        debugPrint('Loaded photos: $_photos'); // Debugging log
      });
    } else {
      debugPrint('No photos found in local storage.'); // Debugging log
    }
  }

  /// 로컬 저장소에 사진 목록을 저장하는 함수
  Future<void> _savePhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final String photosJson =
        jsonEncode(_photos.map((e) => e.toJson()).toList());
    await prefs.setString('photos', photosJson);
    debugPrint('Photos saved to local storage.'); // Debugging log
  }

  /// 새로운 사진을 갤러리에 추가하고 로컬 저장소에 저장하는 함수
  Future<void> _addPhoto(String imagePath) async {
    debugPrint('Adding new photo with path: $imagePath'); // Debugging log
    setState(() {
      _photos.add(Photo(
          id: _nextPhotoId,
          url: imagePath,
          title: 'Photo ${_nextPhotoId.toString()}'));
      _nextPhotoId++;
    });
    await _savePhotos(); // 변경된 사진 목록 저장
    debugPrint('Photo added and saved to local storage.'); // Debugging log
  }

  /// 선택한 사진들을 삭제하는 함수
  Future<void> _deleteSelectedPhotos() async {
    debugPrint('Deleting selected photos: $_selectedPhotos'); // Debugging log
    setState(() {
      _photos.removeWhere((photo) => _selectedPhotos.contains(photo.id));
      _selectedPhotos.clear();
      _isDeleting = false;
      _nextPhotoId = _photos.isNotEmpty
          ? _photos.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1
          : 1;
    });
    await _savePhotos(); // 변경된 사진 목록 저장
    debugPrint(
        'Selected photos deleted and saved to local storage.'); // Debugging log
  }

  /// 사진을 업로드하는 함수
  Future<void> _uploadPhoto() async {
    debugPrint('Opening image picker...'); // Debugging log
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      debugPrint('Picked image path: ${image.path}'); // Debugging log
      await _addPhoto(image.path); // 선택한 사진을 갤러리에 추가합니다.
    } else {
      debugPrint('No image selected.'); // Debugging log
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        'Building GalleryAnalyzePage with ${_photos.length} photos'); // Debugging log
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Analyze Page'),
        actions: [
          IconButton(
            icon: Icon(_isDeleting ? Icons.cancel : Icons.delete),
            onPressed: () {
              setState(() {
                _isDeleting = !_isDeleting; // 삭제 모드를 토글합니다.
                _selectedPhotos.clear(); // 삭제 모드 진입 시 선택된 사진 초기화
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'camera') {
                /// 카메라 페이지로 이동하여 사진을 찍고 경로를 받아옵니다.
                debugPrint('Navigating to camera page...'); // Debugging log
                final imagePath = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TakePictureScreen(camera: widget.camera),
                  ),
                );
                if (imagePath != null) {
                  debugPrint(
                      'Received image path: $imagePath'); // Debugging log
                  await _addPhoto(imagePath); // 찍은 사진을 갤러리에 추가합니다.
                }
              } else if (value == 'upload') {
                /// 갤러리에서 사진을 선택하여 추가합니다.
                await _uploadPhoto();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'camera',
                  child: Text('Take Photo'),
                ),
                const PopupMenuItem<String>(
                  value: 'upload',
                  child: Text('Upload Photo'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 각 행에 2개의 사진을 표시
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
            ),
            itemCount: _photos.length,
            itemBuilder: (context, index) {
              final photo = _photos[index];
              debugPrint('Displaying photo: $photo'); // Debugging log
              final isSelected = _selectedPhotos.contains(photo.id);
              return GestureDetector(
                onTap: () async {
                  if (_isDeleting) {
                    setState(() {
                      if (isSelected) {
                        _selectedPhotos.remove(photo.id); // 선택 해제
                      } else {
                        _selectedPhotos.add(photo.id); // 선택 추가
                      }
                    });
                  } else {
                    /// 사진 상세 페이지로 이동
                    debugPrint(
                        'Navigating to photo detail page for photo: $photo'); // Debugging log
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoAnalyzePage(photo: photo),
                      ),
                    );
                    if (result != null && result is int) {
                      setState(() {
                        _photos.removeWhere(
                            (p) => p.id == result); // 반환된 ID로 사진 삭제
                      });
                      await _savePhotos(); // 변경된 사진 목록 저장
                    }
                  }
                },
                child: GridTile(
                  footer: GridTileBar(
                    backgroundColor: Colors.black54,
                    title: Text(photo.title),
                  ),
                  child: Stack(
                    children: [
                      loadImage(photo), // 사진을 로드하여 표시합니다.
                      if (_isDeleting)
                        Positioned(
                          top: 8.0,
                          right: 8.0,
                          child: Icon(
                            Icons.check_circle,
                            color: isSelected
                                ? Colors.blue
                                : Colors.white, // 선택 여부에 따라 색상이 변경됩니다.
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_isDeleting && _selectedPhotos.isNotEmpty)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _deleteSelectedPhotos, // 선택한 사진을 삭제하는 버튼
                backgroundColor: Colors.red,
                child: const Icon(Icons.delete),
              ),
            ),
        ],
      ),
    );
  }
}
