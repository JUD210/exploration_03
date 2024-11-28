import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<String> analyzeImage(
    BuildContext context, Uint8List imageBytes, String apiKey) async {
  // Gemini Flash 모델 설정: 이 모델은 이미지와 텍스트 모두를 읽을 수 있는 멀티모달 모델입니다.
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
    safetySettings: [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
    ],
  );

  String prompt =
      "제공된 이미지를 분석하고, 식별 가능한 객체, 장면 또는 주목할 만한 특징들을 포함하여 상세 설명을 제공해주세요.\n\n[이미지 분류 : {이미지 분류}]\n{이미지 설명}";

  // 지침과 이미지 바이트 데이터를 결합하여 Gemini에 콘텐츠 전달
  final content = [
    Content.multi([
      TextPart(prompt),
      // 수락되는 mime 타입은 image/*입니다.
      DataPart('image/jpeg', imageBytes),
    ])
  ];

  // 모델 실행 후 설명 생성
  final response = await model.generateContent(content);

  return response.text ?? '';
}
