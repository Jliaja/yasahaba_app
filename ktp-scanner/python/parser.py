import csv
import json
import re
import sys


# =========================================================
# CONFIG
# =========================================================

MIN_CONFIDENCE = 10.0

# Area VALUE NIK pada gambar hasil preprocess 1860x1200
NIK_Y_MIN = 180
NIK_Y_MAX = 300

NIK_X_MIN = 420
NIK_X_MAX = 1500

# Area nama
NAMA_Y_MIN = 300
NAMA_Y_MAX = 365

NAMA_X_MIN = 450
NAMA_X_MAX = 1200


# =========================================================
# CLEAN TEXT
# =========================================================

def clean_text(text):

    if not text:
        return ""

    text = text.replace("_", " ")

    text = re.sub(
        r"\s+",
        " ",
        text
    )

    return text.strip()


# =========================================================
# BACA TSV TESSERACT
# =========================================================

def words_from_tsv(tsv_path):

    words = []

    with open(
        tsv_path,
        "r",
        encoding="utf-8-sig",
        newline=""
    ) as f:

        reader = csv.DictReader(
            f,
            delimiter="\t"
        )

        for row in reader:

            if row.get("level") != "5":
                continue

            text = clean_text(
                row.get("text", "")
            )

            if not text:
                continue

            try:

                conf = float(
                    row.get("conf", "-1")
                )

                left = int(
                    row.get("left", 0)
                )

                top = int(
                    row.get("top", 0)
                )

                width = int(
                    row.get("width", 0)
                )

                height = int(
                    row.get("height", 0)
                )

            except ValueError:
                continue

            center_x = left + width / 2
            center_y = top + height / 2

            # =================================================
            # NIK BOLEH CONFIDENCE RENDAH
            #
            # OCR angka NIK sering confidence jelek.
            # Tapi tetap hanya diterima kalau berada di
            # area NIK.
            # =================================================

            is_nik_area = (
                NIK_Y_MIN <= center_y <= NIK_Y_MAX
                and
                NIK_X_MIN <= center_x <= NIK_X_MAX
            )

            if conf < MIN_CONFIDENCE and not is_nik_area:
                continue

            words.append({

                "text": text,

                "upper": text.upper(),

                "left": left,

                "top": top,

                "width": width,

                "height": height,

                "right": left + width,

                "bottom": top + height,

                "center_x": center_x,

                "center_y": center_y,

                "conf": conf

            })

    return words


# =========================================================
# REGION FILTER
# =========================================================

def words_region(
    words,
    y_min,
    y_max,
    x_min,
    x_max
):

    result = []

    for w in words:

        if w["center_y"] < y_min:
            continue

        if w["center_y"] > y_max:
            continue

        if w["center_x"] < x_min:
            continue

        if w["center_x"] > x_max:
            continue

        result.append(w)

    return sorted(
        result,
        key=lambda x: x["left"]
    )


# =========================================================
# JOIN
# =========================================================

def join(words):

    return " ".join(
        w["text"]
        for w in words
    ).strip()


# =========================================================
# NORMALIZE NIK
# =========================================================

def normalize_nik(text):

    if not text:
        return ""

    text = text.upper()

    # =====================================================
    # KOREKSI OCR KHUSUS ANGKA
    #
    # Jangan masukkan koreksi huruf sembarangan.
    # Semua ini hanya digunakan di area NIK.
    # =====================================================

    replacements = {

        "O": "0",
        "Q": "0",
        "D": "0",

        "I": "1",
        "L": "1",

        "Z": "2",

        "S": "5",

        "G": "6",

        "T": "7",

        # OCR sering membaca angka 6 sebagai B/b
        "B": "6",

    }

    for old, new in replacements.items():

        text = text.replace(
            old,
            new
        )

    # Sisakan angka saja

    text = re.sub(
        r"[^0-9]",
        "",
        text
    )

    return text


# =========================================================
# EXTRACT NIK
# =========================================================

def extract_nik(words):

    candidates = words_region(
        words,
        NIK_Y_MIN,
        NIK_Y_MAX,
        NIK_X_MIN,
        NIK_X_MAX
    )

    print()
    print("=" * 50)
    print("[DEBUG NIK]")
    print("=" * 50)

    if not candidates:

        print("Tidak ada kandidat NIK.")

        return ""

    for w in candidates:

        print(
            f"text={w['text']!r} "
            f"conf={w['conf']:.1f} "
            f"x={w['left']} "
            f"y={w['top']} "
            f"w={w['width']} "
            f"h={w['height']}"
        )

    # =====================================================
    # PRIORITAS 1
    #
    # Cari SATU token yang setelah normalisasi
    # menjadi tepat 16 digit.
    # =====================================================

    exact_candidates = []

    for w in candidates:

        normalized = normalize_nik(
            w["text"]
        )

        if len(normalized) == 16:

            exact_candidates.append({

                "nik": normalized,

                "conf": w["conf"],

                "width": w["width"],

                "text": w["text"]

            })

    if exact_candidates:

        # Ambil confidence tertinggi

        exact_candidates.sort(
            key=lambda x: x["conf"],
            reverse=True
        )

        result = exact_candidates[0]["nik"]

        print()
        print(
            "[NIK EXACT]",
            result
        )

        return result

    # =====================================================
    # PRIORITAS 2
    #
    # Gabungkan seluruh token di baris NIK.
    #
    # Contoh:
    #
    # 210504
    # 2b04950001
    #
    # menjadi:
    #
    # 2105042b04950001
    #
    # lalu B -> 6
    # =====================================================

    combined_raw = "".join(
        w["text"]
        for w in candidates
    )

    combined = normalize_nik(
        combined_raw
    )

    print()
    print(
        "[NIK COMBINED]",
        repr(combined_raw),
        "=>",
        combined
    )

    if len(combined) == 16:

        print(
            "[NIK FOUND]",
            combined
        )

        return combined

    # =====================================================
    # PRIORITAS 3
    #
    # Cari kombinasi token sampai menghasilkan 16 digit.
    #
    # Ini menangani OCR yang memecah angka menjadi:
    #
    # 210504
    # 2b0495
    # 0001
    # =====================================================

    normalized_tokens = []

    for w in candidates:

        value = normalize_nik(
            w["text"]
        )

        if not value:
            continue

        normalized_tokens.append(
            value
        )

    # Coba semua kombinasi berurutan

    for start in range(
        len(normalized_tokens)
    ):

        combined = ""

        for end in range(
            start,
            len(normalized_tokens)
        ):

            combined += normalized_tokens[end]

            if len(combined) == 16:

                print(
                    "[NIK COMBINATION]",
                    combined
                )

                return combined

            if len(combined) > 16:
                break

    # =====================================================
    # GAGAL
    # =====================================================

    print(
        "[NIK ERROR] Tidak ditemukan NIK 16 digit."
    )

    return ""


# =========================================================
# EXTRACT NAMA
# =========================================================

def extract_nama(words):

    candidates = words_region(
        words,
        NAMA_Y_MIN,
        NAMA_Y_MAX,
        NAMA_X_MIN,
        NAMA_X_MAX
    )

    nama = join(
        candidates
    )

    # Bersihkan karakter aneh di awal/akhir

    nama = re.sub(
        r"^[^A-Z]+",
        "",
        nama,
        flags=re.I
    )

    nama = re.sub(
        r"[^A-Z .'-]+$",
        "",
        nama,
        flags=re.I
    )

    nama = clean_text(
        nama
    )

    return nama


# =========================================================
# GENERIC FIELD
# =========================================================

def extract_by_y(
    words,
    y_min,
    y_max,
    x_min=400,
    x_max=1300
):

    candidates = words_region(
        words,
        y_min,
        y_max,
        x_min,
        x_max
    )

    return join(
        candidates
    )


# =========================================================
# DATE
# =========================================================

def extract_date(text):

    match = re.search(
        r"\d{2}-\d{2}-\d{4}",
        text
    )

    if match:
        return match.group(0)

    return ""


# =========================================================
# PARSE KTP
# =========================================================

def parse_ktp(tsv_path):

    words = words_from_tsv(
        tsv_path
    )

    if not words:

        raise Exception(
            "Tidak ada data OCR."
        )

    # =====================================================
    # PROVINSI
    # =====================================================

    provinsi_words = words_region(
        words,
        40,
        110,
        650,
        1600
    )

    provinsi = join(
        provinsi_words
    )

    provinsi = re.sub(
        r"^(INSI|PROVINSI)\s*",
        "",
        provinsi,
        flags=re.I
    )

    provinsi = re.sub(
        r"\s*[=_\-|]+.*$",
        "",
        provinsi
    )

    provinsi = clean_text(
        provinsi
    )

    # =====================================================
    # KABUPATEN
    # =====================================================

    kabupaten_words = words_region(
        words,
        110,
        180,
        350,
        1600
    )

    kabupaten = join(
        kabupaten_words
    )

    kabupaten = re.sub(
        r"\s+RIAU$",
        "",
        kabupaten,
        flags=re.I
    )

    kabupaten = clean_text(
        kabupaten
    )

    # =====================================================
    # NIK
    # =====================================================

    nik = extract_nik(
        words
    )

    # =====================================================
    # NAMA
    # =====================================================

    nama = extract_nama(
        words
    )

    # =====================================================
    # TTL
    # =====================================================

    ttl = extract_by_y(
        words,
        365,
        425,
        450,
        1200
    )

    # =====================================================
    # JENIS KELAMIN
    # =====================================================

    jenis_kelamin = extract_by_y(
        words,
        420,
        475,
        450,
        850
    )

    if "LAKI" in jenis_kelamin.upper():

        jenis_kelamin = "LAKI-LAKI"

    elif "PEREMPUAN" in jenis_kelamin.upper():

        jenis_kelamin = "PEREMPUAN"

    # =====================================================
    # ALAMAT
    # =====================================================

    alamat = extract_by_y(
        words,
        470,
        530,
        450,
        1000
    )

    # =====================================================
    # RT/RW
    # =====================================================

    rt_rw = extract_by_y(
        words,
        525,
        585,
        450,
        850
    )

    # =====================================================
    # KELURAHAN
    # =====================================================

    kelurahan = extract_by_y(
        words,
        580,
        645,
        450,
        1100
    )

    # =====================================================
    # KECAMATAN
    # =====================================================

    kecamatan = extract_by_y(
        words,
        635,
        695,
        450,
        850
    )

    # =====================================================
    # AGAMA
    # =====================================================

    agama = extract_by_y(
        words,
        690,
        755,
        450,
        900
    )

    # =====================================================
    # STATUS
    # =====================================================

    status = extract_by_y(
        words,
        745,
        810,
        450,
        950
    )

    # =====================================================
    # PEKERJAAN
    # =====================================================

    pekerjaan = extract_by_y(
        words,
        800,
        865,
        450,
        1150
    )

    # =====================================================
    # KEWARGANEGARAAN
    # =====================================================

    kewarganegaraan = extract_by_y(
        words,
        850,
        915,
        450,
        850
    )

    # =====================================================
    # BERLAKU HINGGA
    # =====================================================

    berlaku_raw = extract_by_y(
        words,
        910,
        990,
        450,
        850
    )

    berlaku = extract_date(
        berlaku_raw
    )

    # =====================================================
    # HASIL
    # =====================================================

    return {

        "provinsi": provinsi,

        "kabupaten": kabupaten,

        "nik": nik,

        "nama": nama,

        "tempat_tanggal_lahir": ttl,

        "jenis_kelamin": jenis_kelamin,

        "alamat": alamat,

        "rt_rw": rt_rw,

        "kelurahan_desa": kelurahan,

        "kecamatan": kecamatan,

        "agama": agama,

        "status_perkawinan": status,

        "pekerjaan": pekerjaan,

        "kewarganegaraan": kewarganegaraan,

        "berlaku_hingga": berlaku

    }


# =========================================================
# MAIN
# =========================================================

if __name__ == "__main__":

    if len(sys.argv) != 3:

        print(
            "Usage:"
        )

        print(
            "py parser.py input.tsv output.json"
        )

        sys.exit(1)

    input_tsv = sys.argv[1]

    output_json = sys.argv[2]

    try:

        result = parse_ktp(
            input_tsv
        )

        with open(
            output_json,
            "w",
            encoding="utf-8"
        ) as f:

            json.dump(
                result,
                f,
                ensure_ascii=False,
                indent=4
            )

        print()
        print("=" * 50)
        print("HASIL OCR KTP")
        print("=" * 50)

        for key, value in result.items():

            print(
                f"{key:25}: {value}"
            )

        print()
        print(
            "JSON tersimpan:",
            output_json
        )

    except Exception as e:

        print(
            "ERROR:",
            e
        )

        sys.exit(1)