from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
import joblib
import numpy as np
import os

recommend_bp = Blueprint('recommend', __name__)

MODEL_PATH   = os.path.join('models', 'xgboost_model.pkl')
ENCODER_PATH = os.path.join('models', 'label_encoder.pkl')
FEATURE_PATH = os.path.join('models', 'feature_encoders.pkl')

model            = joblib.load(MODEL_PATH)
label_encoder    = joblib.load(ENCODER_PATH)
feature_encoders = joblib.load(FEATURE_PATH)

FEATURE_MAP = {
    'face_shape':    'Face Shape',
    'eye_type':      'Eye Type',
    'nose_shape':    'Nose Shape',
    'lip_shape':     'Lip Shape',
    'eyebrow_shape': 'Eyebrow Shape',
    'skin_tone':     'Skin Tone',
}

# Validasi nilai yang boleh masuk
VALID_VALUES = {
    'face_shape':    ['Oval', 'Round', 'Square', 'Heart', 'Oblong'],
    'eye_type':      ['Monolid', 'Double Eyelid', 'Hooded'],
    'nose_shape':    ['Pesek', 'Sedang', 'Mancung'],
    'lip_shape':     ['Tipis', 'Sedang', 'Tebal'],
    'eyebrow_shape': ['Lurus', 'Soft Arch', 'High Arch'],
    'skin_tone':     ['Very Fair', 'Fair', 'Medium', 'Dark']
}

def find_makeup_id(cursor, label_name):
    """
    Fungsi helper untuk mencari ID makeup di database berdasarkan nama label model.
    Menggunakan pencarian case-insensitive dan toleransi kata kunci (seperti 'Peach Coral Look' -> 'Peach Coral').
    """
    if not label_name:
        return None
        
    cleaned_label = str(label_name).strip().lower()
    
    # 1. Coba cari kecocokan persis (case-insensitive)
    cursor.execute(
        "SELECT id FROM makeup_types WHERE LOWER(TRIM(nama)) = %s", 
        (cleaned_label,)
    )
    row = cursor.fetchone()
    if row:
        return row[0]
        
    # 2. Coba cari dengan menghapus kata " Look" di belakang (misal 'Peach Coral Look' -> 'Peach Coral')
    if cleaned_label.endswith(" look"):
        simplified = cleaned_label.replace(" look", "").strip()
        cursor.execute(
            "SELECT id FROM makeup_types WHERE LOWER(TRIM(nama)) = %s", 
            (simplified,)
        )
        row = cursor.fetchone()
        if row:
            return row[0]
            
    # 3. Coba cari menggunakan pencarian sebagian (LIKE)
    cursor.execute(
        "SELECT id FROM makeup_types WHERE LOWER(nama) LIKE %s", 
        (f"%{cleaned_label}%",)
    )
    row = cursor.fetchone()
    if row:
        return row[0]
        
    return None

@recommend_bp.route('/recommend', methods=['POST'])
@jwt_required()
def recommend():
    user_id = get_jwt_identity()
    data    = request.get_json()

    # Cek semua field ada
    required = list(FEATURE_MAP.keys())
    missing  = [k for k in required if k not in data]
    if missing:
        return jsonify({
            'message': f'Field berikut wajib diisi: {", ".join(missing)}'
        }), 400

    # Validasi nilai setiap field (dengan penambahan otomatisasi konversi penulisan)
    errors = {}
    for field in required:
        val = data[field]
        
        # SINKRONISASI OTOMATIS: 
        # Jika nilai berupa string, rapikan spasi dan jadikan Title Case (misal "monolid" -> "Monolid")
        if isinstance(val, str):
            val = val.replace('_', ' ').strip().title()
            data[field] = val # Simpan kembali nilai yang sudah rapi ke objek data

        if val not in VALID_VALUES[field]:
            errors[field] = f'Nilai "{val}" tidak valid. Pilihan: {VALID_VALUES[field]}'

    if errors:
        return jsonify({
            'message': 'Nilai fitur tidak valid',
            'errors':  errors
        }), 400

    # Encode fitur
    try:
        features = []
        for api_key, enc_key in FEATURE_MAP.items():
            encoded = feature_encoders[enc_key].transform([data[api_key]])[0]
            features.append(int(encoded))
    except Exception as e:
        return jsonify({'message': f'Error encoding: {str(e)}'}), 400

    # Prediksi menggunakan model XGBoost
    features_arr = np.array(features).reshape(1, -1)
    proba        = model.predict_proba(features_arr)[0]
    top2_idx     = np.argsort(proba)[::-1][:2]

    top1_label = label_encoder.classes_[top2_idx[0]]
    top2_label = label_encoder.classes_[top2_idx[1]]
    top1_score = float(proba[top2_idx[0]])
    top2_score = float(proba[top2_idx[1]])

    print(f"=== SEMUA LABEL MODEL ===")
    print(label_encoder.classes_)
    print(f"top1_label dari model: '{top1_label}'")
    print(f"top2_label dari model: '{top2_label}'")
    
    db     = current_app.get_db()
    cursor = db.cursor()

    # Menggunakan fungsi pencarian pintar untuk menghindari crash / missmatch
    top1_id = find_makeup_id(cursor, top1_label)
    top2_id = find_makeup_id(cursor, top2_label)

    print(f"ID Database Terpilih -> top1_id: {top1_id}, top2_id: {top2_id}")

    # Fallback darurat jika ID sama sekali tidak ketemu di database
    # Ini mencegah agar database tidak menyimpan ID NULL atau melakukan query tanpa target
    if top1_id is None:
        top1_id = 1  # default fallback ke ID pertama (Douyin) jika database kosong/tidak cocok
    if top2_id is None:
        top2_id = 2  # default fallback ke ID kedua (Korean)

    cursor.execute("""
        INSERT INTO recommendations
        (user_id, face_shape, eye_type, nose_shape, lip_shape,
         eyebrow_shape, skin_tone, top1_makeup_id, top1_score,
         top2_makeup_id, top2_score)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
    """, (
        user_id,
        data['face_shape'], data['eye_type'],    data['nose_shape'],
        data['lip_shape'],  data['eyebrow_shape'], data['skin_tone'],
        top1_id, top1_score, top2_id, top2_score
    ))
    db.commit()

    # Mengambil rincian detail data makeup untuk dikirimkan kembali ke Flutter
    cursor.execute(
        "SELECT nama, deskripsi, tips, image_url FROM makeup_types WHERE id = %s",
        (top1_id,))
    top1_detail = cursor.fetchone()

    cursor.execute(
        "SELECT nama, deskripsi, tips, image_url FROM makeup_types WHERE id = %s",
        (top2_id,))
    top2_detail = cursor.fetchone()
    
    cursor.close()
    db.close()

    return jsonify({
        'face_features': {
            'face_shape':    data['face_shape'],
            'eye_type':      data['eye_type'],
            'nose_shape':    data['nose_shape'],
            'lip_shape':     data['lip_shape'],
            'eyebrow_shape': data['eyebrow_shape'],
            'skin_tone':     data['skin_tone']
        },
        'top1': {
            'makeup_id': top1_id,
            'nama':      top1_detail[0] if top1_detail else "Unknown",
            'deskripsi': top1_detail[1] if top1_detail else "",
            'tips':      top1_detail[2] if top1_detail else "",
            'image_url': top1_detail[3] if top1_detail else "",
            'score':     round(top1_score, 4)
        },
        'top2': {
            'makeup_id': top2_id,
            'nama':      top2_detail[0] if top2_detail else "Unknown",
            'deskripsi': top2_detail[1] if top2_detail else "",
            'tips':      top2_detail[2] if top2_detail else "",
            'image_url': top2_detail[3] if top2_detail else "",
            'score':     round(top2_score, 4)
        }
    }), 200


@recommend_bp.route('/history', methods=['GET'])
@jwt_required()
def history():
    user_id = get_jwt_identity()
    db      = current_app.get_db()
    cursor  = db.cursor()
    cursor.execute("""
        SELECT r.id, r.face_shape, r.eye_type, r.skin_tone,
               m1.nama, m1.image_url, r.top1_score, r.created_at
        FROM recommendations r
        JOIN makeup_types m1 ON r.top1_makeup_id = m1.id
        WHERE r.user_id = %s
        ORDER BY r.created_at DESC
    """, (user_id,))
    rows = cursor.fetchall()
    cursor.close()
    db.close()

    result = [{
        'id':             r[0],
        'face_shape':     r[1],
        'eye_type':       r[2],
        'skin_tone':      r[3],
        'top1_nama':      r[4],
        'top1_image_url': r[5],
        'top1_score':     float(r[6]),
        'created_at':     str(r[7])
    } for r in rows]

    return jsonify(result), 200