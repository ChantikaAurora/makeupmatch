# 💄 MakeupMatch

MakeupMatch adalah aplikasi mobile berbasis **Flutter** yang memberikan rekomendasi makeup secara personal dengan memanfaatkan **computer vision** dan **machine learning**. Aplikasi ini menganalisis bentuk wajah pengguna melalui foto, lalu memberikan rekomendasi produk/gaya makeup yang paling sesuai.

Proyek ini merupakan **capstone project** yang juga telah diangkat menjadi paper akademik dan disubmit ke jurnal **IJASEIT** dan **Algoritme**.

---

## ✨ Fitur Utama

- 📸 **Deteksi Bentuk Wajah** — menggunakan model **MobileNetV2** untuk mengklasifikasikan bentuk wajah pengguna dari foto (misal: oval, bulat, persegi, hati, dll).
- 💡 **Rekomendasi Makeup Personal** — menggunakan model **XGBoost** untuk menghasilkan rekomendasi makeup berdasarkan hasil klasifikasi bentuk wajah.
- 🔐 **Autentikasi Pengguna** — sistem login/register aman menggunakan **JWT (JSON Web Token)**.
- 🎨 **UI Modern & Estetik** — desain antarmuka dengan tema *"Lunar Bloom"*, nuansa floral yang lembut dan elegan.
- 📱 **Cross-Platform** — dibangun dengan Flutter sehingga dapat berjalan di Android maupun iOS.

---

## 🛠️ Tech Stack

**Frontend (Mobile App)**
- Flutter & Dart

**Backend**
- Flask (Python) — REST API dengan 10 endpoint
- JWT Authentication
- MySQL (via XAMPP)

**Machine Learning**
- MobileNetV2 (TensorFlow Lite) — klasifikasi bentuk wajah
- XGBoost — model rekomendasi makeup

**Desain UI/UX**
- Visily (tema "Lunar Bloom")

---

## 🏗️ Arsitektur Sistem

```
┌─────────────────┐        ┌──────────────────┐        ┌──────────────────┐
│  Flutter Mobile │  --->  │   Flask REST API │  --->  │   MySQL Database │
│   (Frontend)    │  <---  │   (Backend)      │  <---  │                  │
└─────────────────┘        └──────────────────┘        └──────────────────┘
                                     │
                                     ▼
                     ┌───────────────────────────────┐
                     │  ML Models                    │
                     │  - MobileNetV2 (TFLite)       │
                     │  - XGBoost                    │
                     └───────────────────────────────┘
```

---

## 🚀 Instalasi & Menjalankan Proyek

### Prasyarat
- Flutter SDK (versi terbaru disarankan)
- Python 3.11+
- XAMPP (untuk MySQL)
- Xcode (jika ingin menjalankan di iOS)
- Android Studio (jika ingin menjalankan di Android)

### 1. Clone Repository
```bash
git clone https://github.com/username/makeupmatch.git
cd makeupmatch
```

### 2. Setup Backend (Flask API)
```bash
cd backend
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

Buat file `.env` untuk konfigurasi database dan JWT secret:
```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=makeupmatch
JWT_SECRET_KEY=your_secret_key
```

Jalankan server:
```bash
python app.py
```

### 3. Setup Database
- Jalankan XAMPP dan aktifkan MySQL
- Import file `database/makeupmatch.sql` ke phpMyAdmin

### 4. Setup Frontend (Flutter)
```bash
cd ../frontend
flutter pub get
flutter run
```

> ⚠️ **Catatan:** Pastikan versi Flutter SDK sesuai dengan yang tertera di `pubspec.yaml` untuk menghindari crash Dart VM pada perangkat fisik.

---

## 📡 API Endpoints (Ringkasan)

| Method | Endpoint              | Deskripsi                          |
|--------|------------------------|-------------------------------------|
| POST   | `/api/register`        | Registrasi pengguna baru           |
| POST   | `/api/login`           | Login & mendapatkan JWT token      |
| POST   | `/api/upload-photo`    | Unggah foto untuk deteksi wajah    |
| GET    | `/api/face-shape`      | Hasil klasifikasi bentuk wajah     |
| GET    | `/api/recommendation`  | Rekomendasi makeup                 |
| ...    | ...                     | *(lengkapi sesuai endpoint asli)*  |

---

## 📱 Tampilan Aplikasi

*(tambahkan screenshot UI di sini, misal:)*

```
docs/screenshots/home.png
docs/screenshots/result.png
```

---

## 📄 Publikasi Terkait

Proyek ini telah dituliskan dalam bentuk paper akademik dan disubmit ke:
- **IJASEIT** (International Journal on Advanced Science, Engineering and Information Technology)
- **Algoritme** (via OJS)

---

## 👩‍💻 Kontributor

- **Chantika Aurora Akmal** — Politeknik Negeri Padang, D4 Teknik Rekayasa Perangkat Lunak

---

## 📃 Lisensi

Proyek ini dibuat untuk keperluan akademik (capstone project). Silakan hubungi penulis untuk penggunaan lebih lanjut.
