import cv2
import sys


def preprocess(input_path, output_path):

    image = cv2.imread(input_path)

    if image is None:
        raise Exception("Gagal membaca gambar")

    h, w = image.shape[:2]

    print(f"Gambar asli: {w}x{h}")

    # =========================================================
    # 1. CROP AREA KTP
    # =========================================================

    crop = image[
        190:790,
        60:990
    ]

    print(f"Crop: {crop.shape[1]}x{crop.shape[0]}")

    # =========================================================
    # 2. UPSCALE
    # =========================================================

    crop = cv2.resize(
        crop,
        None,
        fx=2,
        fy=2,
        interpolation=cv2.INTER_CUBIC
    )

    # =========================================================
    # 3. GRAYSCALE
    # =========================================================

    gray = cv2.cvtColor(
        crop,
        cv2.COLOR_BGR2GRAY
    )

    # =========================================================
    # 4. DENOISE
    # =========================================================

    gray = cv2.fastNlMeansDenoising(
        gray,
        None,
        h=10,
        templateWindowSize=7,
        searchWindowSize=21
    )

    # =========================================================
    # 5. CONTRAST
    # CLAHE supaya tulisan lebih jelas
    # =========================================================

    clahe = cv2.createCLAHE(
        clipLimit=2.0,
        tileGridSize=(8, 8)
    )

    enhanced = clahe.apply(gray)

    # =========================================================
    # 6. SHARPENING RINGAN
    # =========================================================

    blurred = cv2.GaussianBlur(
        enhanced,
        (0, 0),
        1.2
    )

    sharpened = cv2.addWeighted(
        enhanced,
        1.5,
        blurred,
        -0.5,
        0
    )

    # =========================================================
    # 7. SIMPAN
    # =========================================================

    success = cv2.imwrite(
        output_path,
        sharpened
    )

    if not success:
        raise Exception("Gagal menyimpan hasil")

    print("Berhasil:", output_path)


if __name__ == "__main__":

    if len(sys.argv) != 3:
        print(
            "Usage: py preprocess.py input.jpg output.jpg"
        )
        sys.exit(1)

    preprocess(
        sys.argv[1],
        sys.argv[2]
    )