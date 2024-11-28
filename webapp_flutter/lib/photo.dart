import 'dart:io';
import 'package:flutter/material.dart';

class Photo {
  final int id; // 사진 ID
  final String url; // 사진의 경로 (파일 URL)
  final String title; // 사진의 제목

  Photo({required this.id, required this.url, required this.title});

  /// Photo 객체를 JSON 형식으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
    };
  }

  /// JSON 형식을 Photo 객체로 변환하는 메서드
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      url: json['url'],
      title: json['title'],
    );
  }
}

/// 사진을 로드하는 함수: 네트워크 이미지인지 파일 이미지인지 확인
Widget loadImage(Photo photo) {
  debugPrint('Loading image for photo: $photo'); // Debugging log
  return photo.url.startsWith('http')
      ? Image.network(photo.url)
      : Image.file(File(photo.url));
}

// 퀘스트 1,2번을 위해 사용된 임시 데이터
// 갤러리/카메라 기능을 넣으면서 쓸모없어짐.
//
// final List<Photo> dummyPhotos = [
//   Photo(id: 4, url: 'https://picsum.photos/198', title: 'Photo 4'),
//   Photo(id: 3, url: 'https://picsum.photos/199', title: 'Photo 3'),
//   Photo(id: 1, url: 'https://picsum.photos/200', title: 'Photo 1'),
//   Photo(id: 2, url: 'https://picsum.photos/201', title: 'Photo 2'),
//   Photo(id: 5, url: 'https://picsum.photos/202', title: 'Photo 5'),
// ];
