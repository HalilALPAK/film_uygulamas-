import requests
import json

# Backend URL
BASE_URL = "http://localhost:5000"

def test_register():
    """Kullanıcı kaydı testi"""
    print("=== Kullanıcı Kaydı Testi ===")
    
    data = {
        "username": "testuser",
        "email": "test@example.com",
        "password": "123456"
    }
    
    response = requests.post(f"{BASE_URL}/register", json=data)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
    print()

def test_login():
    """Kullanıcı girişi testi"""
    print("=== Kullanıcı Girişi Testi ===")
    
    data = {
        "username": "testuser",
        "password": "123456"
    }
    
    response = requests.post(f"{BASE_URL}/login", json=data)
    print(f"Status Code: {response.status_code}")
    result = response.json()
    print(f"Response: {result}")
    
    # Token'ı döndür
    if response.status_code == 200:
        return result.get('token')
    return None

def test_profile(token):
    """Profil bilgileri testi"""
    print("=== Profil Bilgileri Testi ===")
    
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/profile", headers=headers)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
    print()

def test_update_profile(token):
    """Profil güncelleme testi"""
    print("=== Profil Güncelleme Testi ===")
    
    headers = {"Authorization": f"Bearer {token}"}
    data = {
        "username": "testuser_updated"
    }
    
    response = requests.put(f"{BASE_URL}/profile", json=data, headers=headers)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
    print()

def test_change_password(token):
    """Şifre değiştirme testi"""
    print("=== Şifre Değiştirme Testi ===")
    
    headers = {"Authorization": f"Bearer {token}"}
    data = {
        "current_password": "123456",
        "new_password": "newpassword123"
    }
    
    response = requests.post(f"{BASE_URL}/change_password", json=data, headers=headers)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
    print()

def main():
    """Ana test fonksiyonu"""
    print("FilMix Backend API Test Başlatılıyor...\n")
    
    try:
        # API durumunu kontrol et
        response = requests.get(BASE_URL)
        if response.status_code != 200:
            print("Backend servisi çalışmıyor!")
            return
        
        print("Backend servisi çalışıyor ✓\n")
        
        # Testleri çalıştır
        test_register()
        token = test_login()
        
        if token:
            test_profile(token)
            test_update_profile(token)
            test_change_password(token)
            print("Tüm testler başarıyla tamamlandı! ✓")
        else:
            print("Token alınamadı, diğer testler atlandı!")
            
    except requests.exceptions.ConnectionError:
        print("Backend servisine bağlanılamıyor!")
        print("Lütfen önce 'python app.py' ile backend'i başlatın.")
    except Exception as e:
        print(f"Test sırasında hata oluştu: {e}")

if __name__ == "__main__":
    main()
