from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import create_access_token, jwt_required, get_jwt
import bcrypt
import random

auth_bp = Blueprint('auth', __name__)
BLACKLIST = set()

# Penyimpanan OTP sementara di memori (Gunakan Redis/Database untuk produksi)
OTP_STORAGE = {}

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    nama = data.get('nama')
    email = data.get('email')
    password = data.get('password')

    if not all([nama, email, password]):
        return jsonify({'message': 'Semua field wajib diisi'}), 400

    # Cek apakah email sudah terdaftar sebelum kirim OTP
    db = current_app.get_db()
    cursor = db.cursor()
    cursor.execute("SELECT id FROM users WHERE email = %s", (email,))
    user = cursor.fetchone()
    cursor.close()
    db.close()

    if user:
        return jsonify({'message': 'Email sudah terdaftar'}), 409

    # Generate 4 digit OTP
    otp = str(random.randint(1000, 9999))
    OTP_STORAGE[email] = {
        'nama': nama,
        'password': bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8'),
        'otp': otp
    }

    # CETAK DI CONSOLE BACKEND (Simulasi pengiriman email/SMS)
    print(f"\n======== [OTP REGISTRASI UNTUK {email}]: {otp} ========\n")

    return jsonify({'message': 'OTP telah dikirim ke email Anda'}), 200

@auth_bp.route('/verify-otp', methods=['POST'])
def verify_otp():
    data = request.get_json()
    email = data.get('email')
    otp = data.get('otp')

    if not email or not otp:
        return jsonify({'message': 'Email dan OTP wajib diisi'}), 400

    user_data = OTP_STORAGE.get(email)
    if not user_data or user_data['otp'] != otp:
        return jsonify({'message': 'Kode OTP salah atau kedaluwarsa'}), 400

    # Jika OTP Valid, masukkan ke Database
    try:
        db = current_app.get_db()
        cursor = db.cursor()
        cursor.execute(
            "INSERT INTO users (nama, email, password) VALUES (%s, %s, %s)",
            (user_data['nama'], email, user_data['password'])
        )
        db.commit()
        cursor.close()
        db.close()
        
        # Hapus data OTP setelah sukses registrasi
        OTP_STORAGE.pop(email, None)
        return jsonify({'message': 'Registrasi berhasil, akun Anda aktif!'}), 201
    except Exception as e:
        return jsonify({'message': 'Terjadi kesalahan basis data'}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    db = current_app.get_db()
    cursor = db.cursor()
    cursor.execute("SELECT id, nama, password FROM users WHERE email = %s", (email,))
    user = cursor.fetchone()
    cursor.close()
    db.close()

    if not user or not bcrypt.checkpw(password.encode('utf-8'), user[2].encode('utf-8')):
        return jsonify({'message': 'Email atau password salah'}), 401

    token = create_access_token(identity=str(user[0]))
    return jsonify({
        'access_token': token,
        'user': {'id': user[0], 'nama': user[1], 'email': email}
    }), 200

@auth_bp.route('/google-login', methods=['POST'])
def google_login():
    data = request.get_json()
    email = data.get('email')
    nama = data.get('nama')
    
    if not email:
        return jsonify({'message': 'Google Auth gagal'}), 400

    db = current_app.get_db()
    cursor = db.cursor()
    cursor.execute("SELECT id, nama FROM users WHERE email = %s", (email,))
    user = cursor.fetchone()

    if not user:
        # Jika belum terdaftar, otomatis buat akun dummy password
        hashed_dummy = bcrypt.hashpw(b'google_auth_dummy_123', bcrypt.gensalt()).decode('utf-8')
        cursor.execute(
            "INSERT INTO users (nama, email, password) VALUES (%s, %s, %s)",
            (nama or 'Google User', email, hashed_dummy)
        )
        db.commit()
        cursor.execute("SELECT id, nama FROM users WHERE email = %s", (email,))
        user = cursor.fetchone()

    cursor.close()
    db.close()

    token = create_access_token(identity=str(user[0]))
    return jsonify({
        'access_token': token,
        'user': {'id': user[0], 'nama': user[1], 'email': email}
    }), 200

@auth_bp.route('/forgot-password', methods=['POST'])
def forgot_password():
    data = request.get_json()
    email = data.get('email')
    new_password = data.get('password')

    if not email or not new_password:
        return jsonify({'message': 'Email dan password baru wajib diisi'}), 400

    hashed = bcrypt.hashpw(new_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

    db = current_app.get_db()
    cursor = db.cursor()
    cursor.execute("SELECT id FROM users WHERE email = %s", (email,))
    user = cursor.fetchone()

    if not user:
        cursor.close()
        db.close()
        return jsonify({'message': 'Email tidak terdaftar'}), 404

    cursor.execute("UPDATE users SET password = %s WHERE email = %s", (hashed, email))
    db.commit()
    cursor.close()
    db.close()

    return jsonify({'message': 'Password berhasil diperbarui'}), 200

@auth_bp.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    jti = get_jwt()['jti']  
    BLACKLIST.add(jti)
    return jsonify({'message': 'Logout berhasil'}), 200