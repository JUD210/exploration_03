# Exploration 03 Project - semantic_segmentation : 민혁, 조규원, 신상호, 고은비

## 루브릭

![alt text](readme_data/image.png)

평가문항 -> 상세기준

1. 인물모드 사진을 성공적으로 제작하였다. 아웃포커싱 효과가 적용된 인물모드 사진과 동물 사진, 배경전환 크로마키사진을 각각 1장 이상 성공적으로 제작하였다.
2. 제작한 인물모드 사진들에서 나타나는 문제점을 정확히 지적하였다. 인물사진에서 발생한 문제점을 정확히 지적한 사진을 제출하였다.
3. 인물모드 사진의 문제점을 개선할 수 있는 솔루션을 적절히 제시하였다. semantic segmentation mask의 오류를 보완할 수 있는 좋은 솔루션을 이유와 함께 제시하였다.

 ![할머니2](https://github.com/user-attachments/assets/6b981c50-4c52-4bea-bcee-74824c54f265)![할머니](https://github.com/user-attachments/assets/0cbef9b4-9864-4f90-8f3b-11b84d1bb543)

처음 할머니와 할머니가 같이 들고있는 배추를 함께 자르려고 했는데 할머니 '신체' 부분만 잘리는 문제가 생겼다.

이후 모델을 변경하여

![할머니 누끼 성공](https://github.com/user-attachments/assets/065b3c9d-4ed7-4cbb-871b-557998b61ece)
성공적으로 누끼를 따는 모습을 볼 수 있다.
![강아지 털](https://github.com/user-attachments/assets/7f2e37a2-a4bd-4c61-9fc3-d039a1e90e30)

기존에 실행했었던 강아지 누끼도 털 부분도 세세하게 잘라주는 모습을 볼 수 있다.


![배경합성 실패](https://github.com/user-attachments/assets/c02120ff-0911-4792-98fe-ad0d9786bbf8)


![배경합성 실패2](https://github.com/user-attachments/assets/cd0c4ce3-58d1-4887-8734-6b21f9b2eb0c)

기존에 피라미드 사진과 배추할머니 사진을 같이 합성해보려고 하였지만 합성 후에 할머니가 사라지는 문제가 생겼다.

![배경합성 성공](https://github.com/user-attachments/assets/d8981fcc-2f91-4443-a0d2-3d6e69b3fdc5)

코드 수정 후 같이 잘 합성되는 모습을 볼 수 있다.

![배경 합성 성공2](https://github.com/user-attachments/assets/2433e0bb-69c8-4b43-8252-0448c0d54746)

추가적으로 실행한 강아지 합성

## 코더 회고

- 배운 점
  - 고은비:
  - 민혁
    - Hugging Face에 업로드된 RMBG-2.0 모델을 활용하여 이미지 배경을 제거하는 방법을 체험해보았다.
    - 누끼 딴 이미지를 배경에다가 살포시 올려놓는 기능까지 체험해보았다.
    - `o1-preview` 에게 적당한 샘플 코드와 적당한 프롬프트만 던져줘도 별다른 에러 없이 매우 긴 코드를 잘 짜주는 것을 보고, 앞으로 코딩은 개발자들의 전유물이 아니겠구나 하는 사실을 다시금 뼈저리게 느낄 수 있었다.
    - 팀원들 각자가 역할을 맡고 성실하게 수행하면, 혼자서는 이뤄낼 수 없는 큰 성과를 단번에 해낼 수 있다는 사실을 다시금 깨달았다. 이래서 팀웍이 중요하구나 새삼스레 느낀다.
    - 팀 내에 분위기 메이커(?) 역할을 할 사람이 있으면, 전체적인 사기가 대폭 증진될 수 있음을 느꼈다.
  - 조규원:
  - 신상호:

- 아쉬운 점
  - 고은비:
  - 민혁
    - 다양하게 실험해보거나 추가해보고 싶은 기능이 많았지만, 시간이 없어서 중간에 그만둬야 했던 점.
    - 모델 구현 부분은 아예 완전히 팀원 분들에게 맡겨서, 지식이 얕은 상태라는 점.
  - 조규원:
  - 신상호:

- 느낀 점
  - 고은비:
  - 민혁: 무조건 팀으로 하자! 그리고 o1-preview '잘' 활용하자!
  - 조규원:
  - 신상호:

- 어려웠던 점
  - 고은비:
  - 민혁: 전 날에 집안 일과 교회 일 등으로 인하여 잠을 2시간 밖에 못 잤다. 심장이 지금 너무 빨리 뛴다. 근데 이건 두근거림일까? 죽음의 징조일까? 모르겠지만 일단 너무 재밌고 신나서 미치겠다. 아이펠톤이 너무너무너무너무 기대된다.
  - 조규원:
  - 신상호:

## 피어리뷰 템플릿

🤔 피어리뷰 템플릿

- 코더: 고은비, 민 혁, 조규원, 신상호
- 리뷰어: ?

- [x]  **1. 주어진 문제를 해결하는 완성된 코드가 제출되었나요? (완성도)**
  - 문제에서 요구하는 최종 결과물이 첨부되었는지 확인
  - 문제를 해결하는 완성된 코드란 프로젝트 루브릭 3개 중 2개,
    퀘스트 문제 요구조건 등을 지칭
    - 해당 조건을 만족하는 부분의 코드 및 결과물을 캡쳐하여 사진으로 첨부

- [x]  **2. 프로젝트에서 핵심적인 부분에 대한 설명이 주석(닥스트링) 및 마크다운 형태로 잘 기록되어있나요? (설명)**
  - [x]  모델 선정 이유
  - [x]  하이퍼 파라미터 선정 이유
  - [x]  데이터 전처리 이유 또는 방법 설명

- [x]  **3. 체크리스트에 해당하는 항목들을 수행하였나요? (문제 해결)**
  - [x]  데이터를 분할하여 프로젝트를 진행했나요? (train, validation, test 데이터로 구분)
  - [x]  하이퍼파라미터를 변경해가며 여러 시도를 했나요? (learning rate, dropout rate, unit, batch size, epoch 등)
  - [x]  각 실험을 시각화하여 비교하였나요?
  - [x]  모든 실험 결과가 기록되었나요?

- [x]  **4. 프로젝트에 대한 회고가 상세히 기록 되어 있나요? (회고, 정리)**
  - [x]  배운 점
  - [x]  아쉬운 점
  - [x]  느낀 점
  - [x]  어려웠던 점

- [x]  **5.  앱으로 구현하였나요?**
  - [x]  구현된 앱이 잘 동작한다.
  - [x]  모델이 잘 동작한다.

## 리뷰어 회고(참고 링크 및 코드 개선)

```Plaintext
?:
?:
?:
```
