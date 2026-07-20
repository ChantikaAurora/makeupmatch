from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity

makeup_bp = Blueprint('makeup', __name__)

# Nilai valid untuk setiap fitur
VALID_VALUES = {
    'face_shape':    ['Oval', 'Round', 'Square', 'Heart', 'Oblong'],
    'eye_type':      ['Monolid', 'Double Eyelid', 'Hooded'],
    'nose_shape':    ['Pesek', 'Sedang', 'Mancung'],
    'lip_shape':     ['Tipis', 'Sedang', 'Tebal'],
    'eyebrow_shape': ['Lurus', 'Soft Arch', 'High Arch'],
    'skin_tone':     ['Very Fair', 'Fair', 'Medium', 'Dark']
}

# GET /api/makeup-types
@makeup_bp.route('/makeup-types', methods=['GET'])
def get_all_makeup():
    db     = current_app.get_db()
    cursor = db.cursor()
    cursor.execute("""
        SELECT id, nama, deskripsi, tips, image_url, created_at
        FROM makeup_types
        ORDER BY id ASC
    """)
    rows = cursor.fetchall()
    cursor.close()
    db.close()

    result = [{
        'id':         r[0],
        'nama':       r[1],
        'deskripsi':  r[2],
        'tips':       r[3],
        'image_url':  r[4],
        'created_at': str(r[5])
    } for r in rows]

    return jsonify(result), 200


# GET /api/makeup-types/<id> 
# Detail satu tipe makeup
@makeup_bp.route('/makeup-types/<int:makeup_id>', methods=['GET'])
def get_makeup_detail(makeup_id):
    db     = current_app.get_db()
    cursor = db.cursor()
    cursor.execute("""
        SELECT id, nama, deskripsi, tips, image_url, created_at
        FROM makeup_types
        WHERE id = %s
    """, (makeup_id,))
    row = cursor.fetchone()
    cursor.close()
    db.close()

    if not row:
        return jsonify({'message': 'Tipe makeup tidak ditemukan'}), 404

    return jsonify({
        'id':         row[0],
        'nama':       row[1],
        'deskripsi':  row[2],
        'tips':       row[3],
        'image_url':  row[4],
        'created_at': str(row[5])
    }), 200


# GET /api/profile 
# Data profil user yang sedang login
@makeup_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    user_id = get_jwt_identity()
    db      = current_app.get_db()
    cursor  = db.cursor()
    cursor.execute("""
        SELECT id, nama, email, created_at
        FROM users
        WHERE id = %s
    """, (user_id,))
    row = cursor.fetchone()
    cursor.close()
    db.close()

    if not row:
        return jsonify({'message': 'User tidak ditemukan'}), 404

    return jsonify({
        'id':         row[0],
        'nama':       row[1],
        'email':      row[2],
        'created_at': str(row[3])
    }), 200

# PUT /api/profile
@makeup_bp.route('/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    user_id = get_jwt_identity()
    data    = request.get_json()
    nama    = data.get('nama', '').strip()

    if not nama:
        return jsonify({'message': 'Nama tidak boleh kosong'}), 400

    if len(nama) > 100:
        return jsonify({'message': 'Nama maksimal 100 karakter'}), 400

    db     = current_app.get_db()
    cursor = db.cursor()
    cursor.execute("""
        UPDATE users SET nama = %s WHERE id = %s
    """, (nama, user_id))
    db.commit()
    cursor.close()
    db.close()

    return jsonify({'message': 'Profil berhasil diperbarui', 'nama': nama}), 200

# GET /api/validate-features 
# Endpoint untuk Flutter cek nilai valid setiap fitur
@makeup_bp.route('/validate-features', methods=['GET'])
def get_valid_features():
    return jsonify(VALID_VALUES), 200