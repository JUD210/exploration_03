# 필요한 라이브러리 임포트
from fastapi import FastAPI, File, UploadFile
import uvicorn
from fastapi.responses import StreamingResponse
from io import BytesIO
from transformers import AutoModelForImageSegmentation
import torch
from torchvision import transforms
from PIL import Image, ImageOps  # ImageOps 추가

# 디바이스 설정 (GPU가 사용 가능하면 GPU 사용)
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# 'remove_bg'로 모델 로드
remove_bg = AutoModelForImageSegmentation.from_pretrained(
    "briaai/RMBG-2.0", trust_remote_code=True
)
remove_bg.to(device)
remove_bg.eval()  # 평가 모드로 설정


# 이미지 전처리 함수 정의
def transform_image(image):
    # 이미지가 RGBA 모드이면 RGB로 변환
    if image.mode == "RGBA":
        image = image.convert("RGB")
    image_size = (1024, 1024)
    transform = transforms.Compose(
        [
            transforms.Resize(image_size),  # 이미지 크기 조정
            transforms.ToTensor(),          # 텐서로 변환
            transforms.Normalize(           # 정규화
                mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]
            ),
        ]
    )
    return transform(image)


# 배경 제거 함수 정의
def remove_background(image):
    # 이미지 전처리
    input_image = transform_image(image).unsqueeze(0).to(device)

    # 모델 추론 (백그라운드 마스크 예측)
    with torch.no_grad():
        preds = remove_bg(input_image)[-1].sigmoid().cpu()
    pred = preds[0].squeeze()

    # 마스크를 PIL 이미지로 변환하고 원본 이미지 크기로 리사이즈
    pred_pil = transforms.ToPILImage()(pred)
    mask = pred_pil.resize(image.size)

    # 원본 이미지에 알파 채널(마스크) 추가
    image.putalpha(mask)
    return image  # 배경이 제거된 이미지 반환


# FastAPI 앱 생성
app = FastAPI()


# 엔드포인트 정의
@app.post("/remove_bg")
async def remove_bg_endpoint(file: UploadFile = File(...)):
    # 업로드된 파일 읽기
    contents = await file.read()
    image = Image.open(BytesIO(contents))

    # EXIF 회전 정보 적용
    image = ImageOps.exif_transpose(image)

    # 필요하면 RGB로 변환
    image = image.convert("RGB")

    # 배경 제거 수행
    result_image = remove_background(image)

    # 결과 이미지를 바이트 스트림으로 변환
    buffered = BytesIO()
    result_image.save(buffered, format="PNG")
    buffered.seek(0)

    # 결과 이미지를 응답으로 반환
    return StreamingResponse(buffered, media_type="image/png")


# 서버 실행
if __name__ == "__main__":
    uvicorn.run(
        "server_fastapi_rmbg:app",
        reload=True,  # 코드 변경 시 자동 리로드
        host="127.0.0.1",  # 로컬호스트
        port=12530,  # 포트
        log_level="info",  # 로깅 레벨
    )