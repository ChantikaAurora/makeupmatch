from flask import Flask, jsonify
from flask_jwt_extended import JWTManager
from flask_cors import CORS
import mysql.connector
from config import Config

app = Flask(__name__)
app.config.from_object(Config)
jwt = JWTManager(app)

CORS(app, resources={
    r"/api/*": {
        "origins": "*",
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"],
        "expose_headers": ["Content-Type", "Authorization"]
    },
    r"/static/*": {
        "origins": "*",
        "methods": ["GET", "OPTIONS"]
    }
})

def get_db():
    return mysql.connector.connect(
        host=app.config['MYSQL_HOST'],
        user=app.config['MYSQL_USER'],
        password=app.config['MYSQL_PASSWORD'],
        database=app.config['MYSQL_DB']
    )

app.get_db = get_db

from routes.auth import auth_bp, BLACKLIST
from routes.recommend import recommend_bp
from routes.makeup import makeup_bp

@jwt.token_in_blocklist_loader
def check_if_token_blacklisted(jwt_header, jwt_payload):
    return jwt_payload['jti'] in BLACKLIST

@jwt.revoked_token_loader
def revoked_token_callback(jwt_header, jwt_payload):
    return jsonify({'message': 'Token sudah tidak valid, silakan login ulang'}), 401

@app.errorhandler(404)
def not_found(e):
    return jsonify({'message': 'Endpoint tidak ditemukan'}), 404

@app.errorhandler(500)
def server_error(e):
    return jsonify({'message': 'Internal server error'}), 500

app.register_blueprint(auth_bp,      url_prefix='/api/auth')
app.register_blueprint(recommend_bp, url_prefix='/api')
app.register_blueprint(makeup_bp,    url_prefix='/api')

if __name__ == '__main__':
    app.run(debug=True, port=5000, host='0.0.0.0')