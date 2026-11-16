const API_URL = "http://127.0.0.1:5000";

const fileInput = document.getElementById("fileInput");
const selectButton = document.getElementById("selectButton");
const dropZone = document.getElementById("dropZone");
const fileList = document.getElementById("fileList");
const processButton = document.getElementById("processButton");
const status = document.getElementById("status");
const results = document.getElementById("results");

let selectedFiles = [];


// =========================================================
// SELECT FILE
// =========================================================

selectButton.addEventListener(
    "click",
    (event) => {

        event.stopPropagation();

        fileInput.click();

    }
);


dropZone.addEventListener(
    "click",
    () => {

        fileInput.click();

    }
);


fileInput.addEventListener(
    "change",
    () => {

        addFiles(
            Array.from(fileInput.files)
        );

        // Supaya file yang sama bisa dipilih lagi
        fileInput.value = "";

    }
);


// =========================================================
// DRAG DROP
// =========================================================

dropZone.addEventListener(
    "dragover",
    (event) => {

        event.preventDefault();

        dropZone.classList.add(
            "dragover"
        );

    }
);


dropZone.addEventListener(
    "dragleave",
    () => {

        dropZone.classList.remove(
            "dragover"
        );

    }
);


dropZone.addEventListener(
    "drop",
    (event) => {

        event.preventDefault();

        dropZone.classList.remove(
            "dragover"
        );

        addFiles(
            Array.from(
                event.dataTransfer.files
            )
        );

    }
);


// =========================================================
// ADD FILES
// =========================================================

function addFiles(files) {

    const imageFiles = files.filter(
        file =>
            file.type.startsWith("image/")
            ||
            /\.(jpg|jpeg|png|webp|jfif)$/i.test(
                file.name
            )
    );


    for (const file of imageFiles) {

        const exists = selectedFiles.some(
            existing =>
                existing.name === file.name &&
                existing.size === file.size &&
                existing.lastModified === file.lastModified
        );

        if (!exists) {

            selectedFiles.push(file);

        }

    }


    renderFileList();

}


// =========================================================
// RENDER FILE LIST
// =========================================================

function renderFileList() {

    fileList.innerHTML = "";

    if (selectedFiles.length === 0) {

        processButton.disabled = true;

        return;

    }


    selectedFiles.forEach(
        (file, index) => {

            const item =
                document.createElement("div");

            item.className =
                "file-item";

            item.innerHTML = `
                <span class="file-name">
                    ${escapeHtml(file.name)}
                </span>

                <span class="file-size">
                    ${formatSize(file.size)}
                </span>

                <button
                    type="button"
                    onclick="removeFile(${index})"
                >
                    Hapus
                </button>
            `;

            fileList.appendChild(item);

        }
    );


    processButton.disabled = false;

}


// =========================================================
// REMOVE
// =========================================================

function removeFile(index) {

    selectedFiles.splice(
        index,
        1
    );

    renderFileList();

}


// =========================================================
// PROCESS
// =========================================================

processButton.addEventListener(
    "click",
    processAll
);


async function processAll() {

    if (
        selectedFiles.length === 0
    ) {
        return;
    }


    processButton.disabled = true;

    results.innerHTML = "";

    status.textContent =
        `Mengupload ${selectedFiles.length} KTP...`;


    const formData =
        new FormData();


    selectedFiles.forEach(
        file => {

            formData.append(
                "files",
                file
            );

        }
    );


    try {

        // =================================================
        // CREATE JOB
        // =================================================

        const response =
            await fetch(
                `${API_URL}/api/scan`,
                {
                    method: "POST",
                    body: formData
                }
            );


        const data =
            await response.json();


        if (!response.ok) {

            throw new Error(
                data.error ||
                "Gagal membuat job."
            );

        }


        // =================================================
        // JOBS
        // =================================================

        const jobs =
            data.jobs.filter(
                job => job.success
            );


        if (jobs.length === 0) {

            throw new Error(
                "Tidak ada file yang berhasil dibuat menjadi job."
            );

        }


        status.textContent =
            `${jobs.length} KTP masuk antrian OCR...`;


        // =================================================
        // BUAT CARD
        // =================================================

        jobs.forEach(
            job => {

                createResultCard(
                    job.job_id,
                    job.filename
                );

            }
        );


        // =================================================
        // POLLING SEMUA JOB
        // =================================================

        await Promise.all(
            jobs.map(
                job =>
                    waitForJob(
                        job.job_id
                    )
            )
        );


        status.textContent =
            "Semua KTP selesai diproses.";


    } catch (error) {

        status.innerHTML = `
            <span class="error">
                ERROR: ${escapeHtml(error.message)}
            </span>
        `;

    } finally {

        processButton.disabled = false;

    }

}


// =========================================================
// WAIT JOB
// =========================================================

async function waitForJob(jobId) {

    while (true) {

        const response =
            await fetch(
                `${API_URL}/api/job/${jobId}`
            );


        const data =
            await response.json();


        if (!response.ok) {

            throw new Error(
                data.error ||
                "Gagal membaca status job."
            );

        }


        const job =
            data.job;


        updateResultCard(
            job.job_id,
            job
        );


        // =================================================
        // DONE
        // =================================================

        if (
            job.status === "done"
        ) {

            renderJobResult(
                job
            );

            return job;

        }


        // =================================================
        // ERROR
        // =================================================

        if (
            job.status === "error"
        ) {

            renderJobError(
                job
            );

            return job;

        }


        // =================================================
        // WAIT
        // =================================================

        await sleep(
            700
        );

    }

}


// =========================================================
// CREATE CARD
// =========================================================

function createResultCard(
    jobId,
    filename
) {

    const card =
        document.createElement("div");

    card.className =
        "result-card";

    card.id =
        `job-${jobId}`;


    card.innerHTML = `

        <h3>
            ${escapeHtml(filename)}
        </h3>

        <div class="job-status">
            <span class="status-text">
                Menunggu...
            </span>

            <span class="status-progress">
                0%
            </span>
        </div>

        <div class="progress-bar">
            <div
                class="progress-fill"
                style="width: 0%"
            ></div>
        </div>

        <div class="job-data"></div>

    `;


    results.appendChild(
        card
    );

}


// =========================================================
// UPDATE PROGRESS
// =========================================================

function updateResultCard(
    jobId,
    job
) {

    const card =
        document.getElementById(
            `job-${jobId}`
        );


    if (!card) {
        return;
    }


    const statusText =
        card.querySelector(
            ".status-text"
        );

    const statusProgress =
        card.querySelector(
            ".status-progress"
        );

    const progressFill =
        card.querySelector(
            ".progress-fill"
        );


    statusText.textContent =
        getStepText(
            job.step,
            job.status
        );


    statusProgress.textContent =
        `${job.progress}%`;


    progressFill.style.width =
        `${job.progress}%`;

}


// =========================================================
// RESULT
// =========================================================

function renderJobResult(job) {

    const card =
        document.getElementById(
            `job-${job.job_id}`
        );


    if (!card) {
        return;
    }


    const data =
        job.data || {};


    const dataContainer =
        card.querySelector(
            ".job-data"
        );


    dataContainer.innerHTML = `

        ${renderField(
            "NIK",
            data.nik
        )}

        ${renderField(
            "Nama",
            data.nama
        )}

        ${renderField(
            "Tempat/Tgl Lahir",
            data.tempat_tanggal_lahir
        )}

        ${renderField(
            "Jenis Kelamin",
            data.jenis_kelamin
        )}

        ${renderField(
            "Alamat",
            data.alamat
        )}

        ${renderField(
            "RT/RW",
            data.rt_rw
        )}

        ${renderField(
            "Kelurahan",
            data.kelurahan_desa
        )}

        ${renderField(
            "Kecamatan",
            data.kecamatan
        )}

        ${renderField(
            "Agama",
            data.agama
        )}

        ${renderField(
            "Status Perkawinan",
            data.status_perkawinan
        )}

        ${renderField(
            "Pekerjaan",
            data.pekerjaan
        )}

        ${renderField(
            "Kewarganegaraan",
            data.kewarganegaraan
        )}

        ${renderField(
            "Berlaku Hingga",
            data.berlaku_hingga
        )}

    `;


    updateResultCard(
        job.job_id,
        {
            ...job,
            status: "done",
            step: "completed",
            progress: 100
        }
    );

}


// =========================================================
// ERROR
// =========================================================

function renderJobError(job) {

    const card =
        document.getElementById(
            `job-${job.job_id}`
        );


    if (!card) {
        return;
    }


    const dataContainer =
        card.querySelector(
            ".job-data"
        );


    dataContainer.innerHTML = `
        <div class="error">
            ${escapeHtml(
                job.error ||
                "OCR gagal."
            )}
        </div>
    `;

}


// =========================================================
// FIELD
// =========================================================

function renderField(
    label,
    value
) {

    return `
        <div class="result-row">

            <div class="result-label">
                ${escapeHtml(label)}
            </div>

            <div class="result-value">
                ${escapeHtml(
                    value || "-"
                )}
            </div>

        </div>
    `;

}


// =========================================================
// STEP TEXT
// =========================================================

function getStepText(
    step,
    status
) {

    if (status === "queued") {
        return "Menunggu...";
    }

    if (status === "done") {
        return "Selesai";
    }

    if (status === "error") {
        return "Gagal";
    }

    switch (step) {

        case "preprocess":
            return "Preprocess gambar...";

        case "ocr":
            return "Menjalankan OCR...";

        case "parser":
            return "Membaca hasil OCR...";

        case "loading":
            return "Menyiapkan hasil...";

        case "completed":
            return "Selesai";

        default:
            return "Memproses...";

    }

}


// =========================================================
// HELPERS
// =========================================================

function sleep(ms) {

    return new Promise(
        resolve =>
            setTimeout(
                resolve,
                ms
            )
    );

}


function formatSize(bytes) {

    if (bytes < 1024) {

        return `${bytes} B`;

    }

    if (
        bytes <
        1024 * 1024
    ) {

        return `${(
            bytes / 1024
        ).toFixed(1)} KB`;

    }

    return `${(
        bytes /
        (1024 * 1024)
    ).toFixed(1)} MB`;

}


function escapeHtml(value) {

    return String(value)
        .replaceAll(
            "&",
            "&amp;"
        )
        .replaceAll(
            "<",
            "&lt;"
        )
        .replaceAll(
            ">",
            "&gt;"
        )
        .replaceAll(
            '"',
            "&quot;"
        )
        .replaceAll(
            "'",
            "&#039;"
        );

}