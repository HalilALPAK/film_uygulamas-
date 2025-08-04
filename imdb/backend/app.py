from flask import Flask, request, jsonify, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import os
import uuid
from datetime import datetime
import jwt
from functools import wraps

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key-here'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///filmix.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['UPLOAD_FOLDER'] = 'uploads/profile_photos'
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

# İzin verilen dosya uzantıları
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

# Veritabanı başlatma
db = SQLAlchemy(app)
CORS(app)

# Upload klasörünü oluştur
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# Kullanıcı modeli
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    profile_photo = db.Column(db.String(200), default='default.png')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    favorites = db.relationship('Favorite', backref='user', lazy=True, cascade='all, delete-orphan')
    ratings = db.relationship('Rating', backref='user', lazy=True, cascade='all, delete-orphan')
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
    
    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'profile_photo': self.profile_photo,
            'created_at': self.created_at.isoformat()
        }

# Favoriler modeli
class Favorite(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    movie_id = db.Column(db.String(20), nullable=False)  # IMDb ID
    movie_title = db.Column(db.String(200), nullable=False)
    movie_poster = db.Column(db.String(500), nullable=True)
    movie_year = db.Column(db.String(10), nullable=True)
    added_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Unique constraint to prevent duplicate favorites
    __table_args__ = (db.UniqueConstraint('user_id', 'movie_id', name='unique_user_movie'),)
    
    def to_dict(self):
        return {
            'id': self.id,
            'movie_id': self.movie_id,
            'movie_title': self.movie_title,
            'movie_poster': self.movie_poster,
            'movie_year': self.movie_year,
            'added_at': self.added_at.isoformat()
        }

# Puanlama modeli
class Rating(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    movie_id = db.Column(db.String(20), nullable=False)  # IMDb ID
    rating = db.Column(db.Float, nullable=False)  # 1.0 to 5.0
    movie_title = db.Column(db.String(200), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Unique constraint to prevent duplicate ratings
    __table_args__ = (db.UniqueConstraint('user_id', 'movie_id', name='unique_user_movie_rating'),)
    
    def to_dict(self):
        return {
            'id': self.id,
            'movie_id': self.movie_id,
            'movie_title': self.movie_title,
            'rating': self.rating,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }

# Token doğrulama decorator'ı
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        
        if not token:
            return jsonify({'message': 'Token bulunamadı!'}), 401
        
        try:
            if token.startswith('Bearer '):
                token = token[7:]
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=['HS256'])
            current_user = User.query.get(data['user_id'])
            if not current_user:
                return jsonify({'message': 'Geçersiz token!'}), 401
        except:
            return jsonify({'message': 'Geçersiz token!'}), 401
        
        return f(current_user, *args, **kwargs)
    return decorated

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Ana sayfa
@app.route('/')
def index():
    return jsonify({
        'message': 'FilMix Backend API',
        'version': '1.0.0',
        'endpoints': {
            'register': '/register',
            'login': '/login',
            'profile': '/profile',
            'upload_photo': '/upload_photo'
        }
    })

# Kullanıcı kaydı
@app.route('/register', methods=['POST'])
def register():
    try:
        data = request.get_json()
        
        # Veri kontrolü
        if not data or not data.get('username') or not data.get('email') or not data.get('password'):
            return jsonify({'message': 'Kullanıcı adı, email ve şifre gerekli!'}), 400
        
        username = data['username'].strip()
        email = data['email'].strip().lower()
        password = data['password']
        
        # Kullanıcı adı ve email kontrolü
        if User.query.filter_by(username=username).first():
            return jsonify({'message': 'Bu kullanıcı adı zaten kullanılıyor!'}), 400
        
        if User.query.filter_by(email=email).first():
            return jsonify({'message': 'Bu email adresi zaten kayıtlı!'}), 400
        
        # Şifre uzunluk kontrolü
        if len(password) < 6:
            return jsonify({'message': 'Şifre en az 6 karakter olmalıdır!'}), 400
        
        # Yeni kullanıcı oluştur
        user = User(username=username, email=email)
        user.set_password(password)
        
        db.session.add(user)
        db.session.commit()
        
        return jsonify({
            'message': 'Kullanıcı başarıyla kaydedildi!',
            'user': user.to_dict()
        }), 201
        
    except Exception as e:
        return jsonify({'message': f'Kayıt sırasında hata oluştu: {str(e)}'}), 500

# Kullanıcı girişi
@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        
        if not data or not data.get('username') or not data.get('password'):
            return jsonify({'message': 'Kullanıcı adı ve şifre gerekli!'}), 400
        
        username = data['username'].strip()
        password = data['password']
        
        # Kullanıcıyı bul (username veya email ile)
        user = User.query.filter(
            (User.username == username) | (User.email == username)
        ).first()
        
        if not user or not user.check_password(password):
            return jsonify({'message': 'Kullanıcı adı veya şifre hatalı!'}), 401
        
        # JWT token oluştur
        token = jwt.encode({
            'user_id': user.id,
            'username': user.username
        }, app.config['SECRET_KEY'], algorithm='HS256')
        
        return jsonify({
            'message': 'Giriş başarılı!',
            'token': token,
            'user': user.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({'message': f'Giriş sırasında hata oluştu: {str(e)}'}), 500

# Profil bilgilerini getir
@app.route('/profile', methods=['GET'])
@token_required
def get_profile(current_user):
    return jsonify({
        'user': current_user.to_dict()
    }), 200

# Profil bilgilerini güncelle
@app.route('/profile', methods=['PUT'])
@token_required
def update_profile(current_user):
    try:
        data = request.get_json()
        
        if 'username' in data:
            new_username = data['username'].strip()
            if new_username != current_user.username:
                # Kullanıcı adı kontrolü
                if User.query.filter_by(username=new_username).first():
                    return jsonify({'message': 'Bu kullanıcı adı zaten kullanılıyor!'}), 400
                current_user.username = new_username
        
        if 'email' in data:
            new_email = data['email'].strip().lower()
            if new_email != current_user.email:
                # Email kontrolü
                if User.query.filter_by(email=new_email).first():
                    return jsonify({'message': 'Bu email adresi zaten kayıtlı!'}), 400
                current_user.email = new_email
        
        db.session.commit()
        
        return jsonify({
            'message': 'Profil başarıyla güncellendi!',
            'user': current_user.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({'message': f'Profil güncellenirken hata oluştu: {str(e)}'}), 500

# Şifre değiştir
@app.route('/change_password', methods=['POST'])
@token_required
def change_password(current_user):
    try:
        data = request.get_json()
        
        if not data or not data.get('current_password') or not data.get('new_password'):
            return jsonify({'message': 'Mevcut şifre ve yeni şifre gerekli!'}), 400
        
        current_password = data['current_password']
        new_password = data['new_password']
        
        # Mevcut şifre kontrolü
        if not current_user.check_password(current_password):
            return jsonify({'message': 'Mevcut şifre hatalı!'}), 400
        
        # Yeni şifre uzunluk kontrolü
        if len(new_password) < 6:
            return jsonify({'message': 'Yeni şifre en az 6 karakter olmalıdır!'}), 400
        
        # Şifreyi güncelle
        current_user.set_password(new_password)
        db.session.commit()
        
        return jsonify({'message': 'Şifre başarıyla değiştirildi!'}), 200
        
    except Exception as e:
        return jsonify({'message': f'Şifre değiştirilirken hata oluştu: {str(e)}'}), 500

# Profil fotoğrafı yükle
@app.route('/upload_photo', methods=['POST'])
@token_required
def upload_photo(current_user):
    try:
        if 'file' not in request.files:
            return jsonify({'message': 'Dosya seçilmedi!'}), 400
        
        file = request.files['file']
        
        if file.filename == '':
            return jsonify({'message': 'Dosya seçilmedi!'}), 400
        
        if file and allowed_file(file.filename):
            # Eski fotoğrafı sil (default değilse)
            if current_user.profile_photo != 'default.png':
                old_photo_path = os.path.join(app.config['UPLOAD_FOLDER'], current_user.profile_photo)
                if os.path.exists(old_photo_path):
                    os.remove(old_photo_path)
            
            # Yeni dosya adı oluştur
            filename = secure_filename(file.filename)
            unique_filename = f"{uuid.uuid4().hex}_{filename}"
            file_path = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
            
            # Dosyayı kaydet
            file.save(file_path)
            
            # Veritabanını güncelle
            current_user.profile_photo = unique_filename
            db.session.commit()
            
            return jsonify({
                'message': 'Profil fotoğrafı başarıyla güncellendi!',
                'profile_photo': unique_filename,
                'user': current_user.to_dict()
            }), 200
        
        return jsonify({'message': 'Geçersiz dosya formatı! (png, jpg, jpeg, gif)'}), 400
        
    except Exception as e:
        return jsonify({'message': f'Dosya yüklenirken hata oluştu: {str(e)}'}), 500

# Profil fotoğraflarını serve et
@app.route('/profile_photos/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

# Varsayılan profil fotoğrafını sil
@app.route('/reset_photo', methods=['POST'])
@token_required
def reset_photo(current_user):
    try:
        # Eski fotoğrafı sil (default değilse)
        if current_user.profile_photo != 'default.png':
            old_photo_path = os.path.join(app.config['UPLOAD_FOLDER'], current_user.profile_photo)
            if os.path.exists(old_photo_path):
                os.remove(old_photo_path)
        
        # Varsayılan fotoğrafa dön
        current_user.profile_photo = 'default.png'
        db.session.commit()
        
        return jsonify({
            'message': 'Profil fotoğrafı varsayılana döndürüldü!',
            'user': current_user.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({'message': f'Fotoğraf sıfırlanırken hata oluştu: {str(e)}'}), 500

# ==================== FAVORİLER API ====================

# Favorilere film ekleme
@app.route('/favorites', methods=['POST'])
@token_required
def add_favorite(current_user):
    try:
        data = request.get_json()
        
        if not data or 'movie_id' not in data:
            return jsonify({'message': 'Film ID gerekli!'}), 400
        
        movie_id = data['movie_id']
        movie_title = data.get('movie_title', 'Unknown')
        movie_poster = data.get('movie_poster', '')
        movie_year = data.get('movie_year', '')
        
        # Zaten favorilerde mi kontrol et
        existing_favorite = Favorite.query.filter_by(
            user_id=current_user.id, 
            movie_id=movie_id
        ).first()
        
        if existing_favorite:
            return jsonify({'message': 'Film zaten favorilerde!'}), 400
        
        # Yeni favori oluştur
        new_favorite = Favorite(
            user_id=current_user.id,
            movie_id=movie_id,
            movie_title=movie_title,
            movie_poster=movie_poster,
            movie_year=movie_year
        )
        
        db.session.add(new_favorite)
        db.session.commit()
        
        return jsonify({
            'message': 'Film favorilere eklendi!',
            'favorite': new_favorite.to_dict()
        }), 201
        
    except Exception as e:
        return jsonify({'message': f'Favorilere ekleme hatası: {str(e)}'}), 500

# Favorilerden film çıkarma
@app.route('/favorites/<movie_id>', methods=['DELETE'])
@token_required
def remove_favorite(current_user, movie_id):
    try:
        favorite = Favorite.query.filter_by(
            user_id=current_user.id,
            movie_id=movie_id
        ).first()
        
        if not favorite:
            return jsonify({'message': 'Film favorilerde bulunamadı!'}), 404
        
        db.session.delete(favorite)
        db.session.commit()
        
        return jsonify({'message': 'Film favorilerden çıkarıldı!'}), 200
        
    except Exception as e:
        return jsonify({'message': f'Favorilerden çıkarma hatası: {str(e)}'}), 500

# Kullanıcının favori filmlerini listeleme
@app.route('/favorites', methods=['GET'])
@token_required
def get_favorites(current_user):
    try:
        favorites = Favorite.query.filter_by(user_id=current_user.id).order_by(Favorite.added_at.desc()).all()
        
        return jsonify({
            'favorites': [favorite.to_dict() for favorite in favorites],
            'count': len(favorites)
        }), 200
        
    except Exception as e:
        return jsonify({'message': f'Favoriler alınırken hata: {str(e)}'}), 500

# Film favoride mi kontrol et
@app.route('/favorites/check/<movie_id>', methods=['GET'])
@token_required
def check_favorite(current_user, movie_id):
    try:
        favorite = Favorite.query.filter_by(
            user_id=current_user.id,
            movie_id=movie_id
        ).first()
        
        return jsonify({'is_favorite': favorite is not None}), 200
        
    except Exception as e:
        return jsonify({'message': f'Favori kontrolü hatası: {str(e)}'}), 500

# ==================== PUANLAMA API ====================

# Film puanlama
@app.route('/ratings', methods=['POST'])
@token_required
def rate_movie(current_user):
    try:
        data = request.get_json()
        
        if not data or 'movie_id' not in data or 'rating' not in data:
            return jsonify({'message': 'Film ID ve puan gerekli!'}), 400
        
        movie_id = data['movie_id']
        rating_value = float(data['rating'])
        movie_title = data.get('movie_title', 'Unknown')
        
        # Puan aralığı kontrolü
        if rating_value < 1.0 or rating_value > 5.0:
            return jsonify({'message': 'Puan 1.0 ile 5.0 arasında olmalı!'}), 400
        
        # Mevcut puanı kontrol et
        existing_rating = Rating.query.filter_by(
            user_id=current_user.id,
            movie_id=movie_id
        ).first()
        
        if existing_rating:
            # Puanı güncelle
            existing_rating.rating = rating_value
            existing_rating.updated_at = datetime.utcnow()
            message = 'Film puanı güncellendi!'
        else:
            # Yeni puan oluştur
            existing_rating = Rating(
                user_id=current_user.id,
                movie_id=movie_id,
                rating=rating_value,
                movie_title=movie_title
            )
            db.session.add(existing_rating)
            message = 'Film puanlandı!'
        
        db.session.commit()
        
        return jsonify({
            'message': message,
            'rating': existing_rating.to_dict()
        }), 201
        
    except Exception as e:
        return jsonify({'message': f'Puanlama hatası: {str(e)}'}), 500

# Film puanını alma
@app.route('/ratings/<movie_id>', methods=['GET'])
@token_required
def get_movie_rating(current_user, movie_id):
    try:
        rating = Rating.query.filter_by(
            user_id=current_user.id,
            movie_id=movie_id
        ).first()
        
        if rating:
            return jsonify({'rating': rating.to_dict()}), 200
        else:
            return jsonify({'rating': None}), 200
        
    except Exception as e:
        return jsonify({'message': f'Puan alınırken hata: {str(e)}'}), 500

# Kullanıcının tüm puanlarını listeleme
@app.route('/ratings', methods=['GET'])
@token_required
def get_user_ratings(current_user):
    try:
        ratings = Rating.query.filter_by(user_id=current_user.id).order_by(Rating.updated_at.desc()).all()
        
        return jsonify({
            'ratings': [rating.to_dict() for rating in ratings],
            'count': len(ratings)
        }), 200
        
    except Exception as e:
        return jsonify({'message': f'Puanlar alınırken hata: {str(e)}'}), 500

# Film puanını silme
@app.route('/ratings/<movie_id>', methods=['DELETE'])
@token_required
def delete_rating(current_user, movie_id):
    try:
        rating = Rating.query.filter_by(
            user_id=current_user.id,
            movie_id=movie_id
        ).first()
        
        if not rating:
            return jsonify({'message': 'Film puanı bulunamadı!'}), 404
        
        db.session.delete(rating)
        db.session.commit()
        
        return jsonify({'message': 'Film puanı silindi!'}), 200
        
    except Exception as e:
        return jsonify({'message': f'Puan silme hatası: {str(e)}'}), 500

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
        print("Veritabanı tabloları oluşturuldu!")
    
    print("FilMix Backend başlatılıyor...")
    print("API Endpoints:")
    print("- POST /register - Kullanıcı kaydı")
    print("- POST /login - Kullanıcı girişi")
    print("- GET /profile - Profil bilgileri")
    print("- PUT /profile - Profil güncelle")
    print("- POST /change_password - Şifre değiştir")
    print("- POST /upload_photo - Profil fotoğrafı yükle")
    print("- POST /reset_photo - Profil fotoğrafını sıfırla")
    print("- GET /profile_photos/<filename> - Profil fotoğraflarını görüntüle")
    print("- POST /favorites - Favorilere film ekleme")
    print("- DELETE /favorites/<movie_id> - Favorilerden film çıkarma")
    print("- GET /favorites - Favori filmleri listeleme")
    print("- GET /favorites/check/<movie_id> - Film favoride mi kontrol")
    print("- POST /ratings - Film puanlama")
    print("- GET /ratings/<movie_id> - Film puanını alma")
    print("- GET /ratings - Kullanıcı puanlarını listeleme")
    print("- DELETE /ratings/<movie_id> - Film puanını silme")
    
    app.run(debug=True, host='0.0.0.0', port=5000)
