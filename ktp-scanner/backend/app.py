import os
import sys
import json
import uuid
import subprocess
import threading
import traceback

from pathlib import Path
from datetime import datetime

from flask import Flask, request, jsonify
from flask_cors import CORS


# =========================================================
# CONFIG
# =========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

PYTHON_DIR = BASE_DIR / "python"

PREPROCESS_SCRIPT = PYTHON_DIR / "preprocess.py"
PARSER_SCRIPT = PYTHON_DIR / "parser.py"

TESSERACT = Path(
    r"D:\Tesseract OCR\tesseract.exe"
)

UPLOAD_DIR = BASE_DIR / "backend" / "uploads"
OUTPUT_DIR = BASE_DIR / "backend" / "outputs"

UPLOAD_DIR.mkdir(
    parents=True,
    exist_ok=True
)

OUTPUT_DIR.mkdir(
    parents=True,
    exist_ok=True
)


# =========================================================
# FLASK
# =========================================================

app = Flask(__name__)

CORS(app)

# Maksimal total upload
app.config["MAX_CONTENT_LENGTH"] = 100 * 1024 * 1024


# =========================================================
# ALLOWED FILE
# =========================================================

ALLOWED_EXTENSIONS = {
    ".jpg",
    ".jpeg",
    ".png",
    ".webp",
    ".jfif",
}


# =========================================================
# JOB STORAGE
# =========================================================

jobs = {}

jobs_lock = threading.Lock()


# =========================================================
# HELPER
# =========================================================

def now():
    return datetime.now().isoformat(
        timespec="seconds"
    )


def allowed_file(filename):

    if not filename:
        return False

    extension = (
        Path(filename)
        .suffix
        .lower()
    )

    return extension in ALLOWED_EXTENSIONS


def update_job(job_id, **kwargs):

    with jobs_lock:

        if job_id not in jobs:
            return

        jobs[job_id].update(kwargs)


def get_job(job_id):

    with jobs_lock:

        job = jobs.get(job_id)

        if job is None:
            return None

        # copy supaya aman
        return dict(job)


def get_all_jobs():

    with jobs_lock:

        return [
            dict(job)
            for job in jobs.values()
        ]


def run_command(command):

    try:

        print()
        print("[COMMAND]")
        print(" ".join(
            f'"{x}"' if " " in str(x)
            else str(x)
            for x in command
        ))

        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace"
        )

        if result.stdout:
            print("[STDOUT]")
            print(result.stdout)

        if result.stderr:
            print("[STDERR]")
            print(result.stderr)

        return result

    except Exception as e:

        raise RuntimeError(
            f"Gagal menjalankan command: {e}"
        )


# =========================================================
# PROCESS SINGLE FILE
# =========================================================

def process_file(
    job_id,
    input_path,
    original_name
):

    work_dir = (
        UPLOAD_DIR / job_id
    )

    processed_path = (
        work_dir / "processed.jpg"
    )

    ocr_base = (
        work_dir / "ocr"
    )

    generated_tsv = (
        work_dir / "ocr.tsv"
    )

    json_path = (
        OUTPUT_DIR / f"{job_id}.json"
    )

    try:

        # =================================================
        # START
        # =================================================

        update_job(
            job_id,
            status="processing",
            step="preprocess",
            progress=5
        )

        print()
        print("=" * 60)
        print(
            f"[{job_id}] START: {original_name}"
        )
        print("=" * 60)


        # =================================================
        # PREPROCESS
        # =================================================

        update_job(
            job_id,
            step="preprocess",
            progress=10
        )

        print(
            f"[{job_id}] PREPROCESS"
        )

        preprocess = run_command([
            sys.executable,
            str(PREPROCESS_SCRIPT),
            str(input_path),
            str(processed_path)
        ])

        if preprocess.returncode != 0:

            raise RuntimeError(
                "Preprocess gagal:\n"
                + (
                    preprocess.stderr
                    or preprocess.stdout
                    or "Unknown error"
                )
            )

        if not processed_path.exists():

            raise RuntimeError(
                "File hasil preprocess "
                "tidak ditemukan."
            )


        # =================================================
        # OCR
        # =================================================

        update_job(
            job_id,
            step="ocr",
            progress=35
        )

        print(
            f"[{job_id}] OCR"
        )

        ocr = run_command([
            str(TESSERACT),
            str(processed_path),
            str(ocr_base),
            "-l",
            "eng",
            "--psm",
            "11",
            "tsv"
        ])

        if ocr.returncode != 0:

            raise RuntimeError(
                "Tesseract OCR gagal:\n"
                + (
                    ocr.stderr
                    or ocr.stdout
                    or "Unknown error"
                )
            )


        # Tesseract output:
        # ocr.tsv

        if not generated_tsv.exists():

            raise RuntimeError(
                "File OCR TSV tidak ditemukan."
            )


        # =================================================
        # PARSER
        # =================================================

        update_job(
            job_id,
            step="parser",
            progress=70
        )

        print(
            f"[{job_id}] PARSER"
        )

        parser = run_command([
            sys.executable,
            str(PARSER_SCRIPT),
            str(generated_tsv),
            str(json_path)
        ])

        if parser.returncode != 0:

            raise RuntimeError(
                "Parser gagal:\n"
                + (
                    parser.stderr
                    or parser.stdout
                    or "Unknown error"
                )
            )


        if not json_path.exists():

            raise RuntimeError(
                "JSON hasil parser "
                "tidak ditemukan."
            )


        # =================================================
        # LOAD JSON
        # =================================================

        update_job(
            job_id,
            step="loading",
            progress=90
        )

        print(
            f"[{job_id}] LOAD JSON"
        )

        with open(
            json_path,
            "r",
            encoding="utf-8"
        ) as f:

            data = json.load(f)


        # =================================================
        # DONE
        # =================================================

        update_job(
            job_id,
            status="done",
            step="completed",
            progress=100,
            data=data,
            finished_at=now()
        )

        print(
            f"[{job_id}] DONE: {original_name}"
        )


    except Exception as e:

        error_message = str(e)

        print()
        print(
            f"[{job_id}] ERROR: "
            f"{original_name}"
        )
        print(error_message)
        print()

        traceback.print_exc()

        update_job(
            job_id,
            status="error",
            step="failed",
            progress=100,
            error=error_message,
            finished_at=now()
        )


# =========================================================
# BACKGROUND WORKER
# =========================================================

def background_process(
    job_id,
    input_path,
    original_name
):

    thread = threading.Thread(
        target=process_file,
        args=(
            job_id,
            input_path,
            original_name
        ),
        daemon=True,
        name=f"ktp-worker-{job_id}"
    )

    thread.start()


# =========================================================
# API
# CREATE SCAN JOB
# =========================================================

@app.route(
    "/api/scan",
    methods=["POST"]
)
def scan():

    files = request.files.getlist(
        "files"
    )

    if not files:

        return jsonify({
            "success": False,
            "error": "Tidak ada file."
        }), 400


    created = []


    for file in files:

        original_name = Path(
            file.filename or ""
        ).name

        if not original_name:
            continue


        # =================================================
        # CHECK EXTENSION
        # =================================================

        if not allowed_file(
            original_name
        ):

            created.append({

                "success": False,

                "filename": original_name,

                "error": (
                    "Format file tidak didukung. "
                    "Gunakan JPG, JPEG, PNG, WEBP, "
                    "atau JFIF."
                )

            })

            continue


        # =================================================
        # CREATE JOB ID
        # =================================================

        job_id = uuid.uuid4().hex

        work_dir = (
            UPLOAD_DIR / job_id
        )

        work_dir.mkdir(
            parents=True,
            exist_ok=True
        )

        input_path = (
            work_dir / original_name
        )


        # =================================================
        # SAVE UPLOAD
        # =================================================

        try:

            file.save(
                input_path
            )

        except Exception as e:

            created.append({

                "success": False,

                "filename": original_name,

                "error": (
                    f"Gagal menyimpan file: {e}"
                )

            })

            continue


        # =================================================
        # REGISTER JOB
        # =================================================

        job = {

            "job_id": job_id,

            "filename": original_name,

            "status": "queued",

            "step": "waiting",

            "progress": 0,

            "created_at": now(),

            "finished_at": None,

            "data": None,

            "error": None

        }


        with jobs_lock:

            jobs[job_id] = job


        # =================================================
        # START BACKGROUND
        # =================================================

        background_process(
            job_id,
            input_path,
            original_name
        )


        # =================================================
        # RESPONSE
        # =================================================

        created.append({

            "success": True,

            "job_id": job_id,

            "filename": original_name,

            "status": "queued"

        })


    return jsonify({

        "success": True,

        "total": len(created),

        "jobs": created

    })


# =========================================================
# GET SINGLE JOB
# =========================================================

@app.route(
    "/api/job/<job_id>",
    methods=["GET"]
)
def job_status(job_id):

    job = get_job(
        job_id
    )

    if job is None:

        return jsonify({

            "success": False,

            "error": "Job tidak ditemukan."

        }), 404


    return jsonify({

        "success": True,

        "job": job

    })


# =========================================================
# GET ALL JOBS
# =========================================================

@app.route(
    "/api/jobs",
    methods=["GET"]
)
def all_jobs():

    result = get_all_jobs()

    # newest first
    result.reverse()

    return jsonify({

        "success": True,

        "total": len(result),

        "jobs": result

    })


# =========================================================
# GET RESULT
# =========================================================

@app.route(
    "/api/result/<job_id>",
    methods=["GET"]
)
def get_result(job_id):

    job = get_job(
        job_id
    )

    if job is None:

        return jsonify({

            "success": False,

            "error": "Job tidak ditemukan."

        }), 404


    if job["status"] == "error":

        return jsonify({

            "success": False,

            "job_id": job_id,

            "filename": job["filename"],

            "status": "error",

            "error": job["error"]

        }), 500


    if job["status"] != "done":

        return jsonify({

            "success": False,

            "job_id": job_id,

            "filename": job["filename"],

            "status": job["status"],

            "progress": job["progress"],

            "error": "Hasil belum tersedia."

        }), 202


    return jsonify({

        "success": True,

        "job_id": job_id,

        "filename": job["filename"],

        "status": "done",

        "data": job["data"]

    })


# =========================================================
# HEALTH CHECK
# =========================================================

@app.route(
    "/api/health",
    methods=["GET"]
)
def health():

    return jsonify({

        "status": "ok",

        "python": sys.executable,

        "tesseract": str(TESSERACT),

        "preprocess": str(
            PREPROCESS_SCRIPT
        ),

        "parser": str(
            PARSER_SCRIPT
        ),

        "preprocess_exists":
            PREPROCESS_SCRIPT.exists(),

        "parser_exists":
            PARSER_SCRIPT.exists(),

        "tesseract_exists":
            TESSERACT.exists()

    })


# =========================================================
# ROOT
# =========================================================

@app.route("/")
def index():

    return jsonify({

        "name": "KTP Scanner Backend",

        "status": "running",

        "message": (
            "Backend aktif. "
            "Gunakan API endpoint."
        ),

        "api": {

            "health":
                "GET /api/health",

            "scan":
                "POST /api/scan",

            "jobs":
                "GET /api/jobs",

            "job":
                "GET /api/job/<job_id>",

            "result":
                "GET /api/result/<job_id>"

        }

    })


# =========================================================
# 413
# =========================================================

@app.errorhandler(413)
def request_too_large(error):

    return jsonify({

        "success": False,

        "error": (
            "Total ukuran upload terlalu besar. "
            "Maksimal 100 MB."
        )

    }), 413


# =========================================================
# GENERAL ERROR
# =========================================================

@app.errorhandler(Exception)
def handle_exception(error):

    print()
    print("[FLASK ERROR]")
    traceback.print_exc()

    return jsonify({

        "success": False,

        "error": str(error)

    }), 500


# =========================================================
# RUN
# =========================================================

if __name__ == "__main__":

    print("=" * 60)
    print("KTP SCANNER BACKEND")
    print("=" * 60)

    print(
        "BASE     :",
        BASE_DIR
    )

    print(
        "PYTHON   :",
        PYTHON_DIR
    )

    print(
        "PREPROCESS:",
        PREPROCESS_SCRIPT
    )

    print(
        "PARSER   :",
        PARSER_SCRIPT
    )

    print(
        "TESSERACT:",
        TESSERACT
    )

    print()

    print(
        "PREPROCESS OK :",
        PREPROCESS_SCRIPT.exists()
    )

    print(
        "PARSER OK     :",
        PARSER_SCRIPT.exists()
    )

    print(
        "TESSERACT OK  :",
        TESSERACT.exists()
    )

    print()

    # =====================================================
    # PENTING:
    #
    # use_reloader=False
    #
    # Supaya background worker tidak dibuat dua kali
    # oleh Flask development reloader.
    # =====================================================

    app.run(
        host="127.0.0.1",
        port=5000,
        debug=True,
        threaded=True,
        use_reloader=False
    )