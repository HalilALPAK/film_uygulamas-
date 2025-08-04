import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'auth_service.dart';
import 'login_register_page.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onLogout;

  const ProfilePage({super.key, this.onLogout});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _userName = 'Kullanıcı Adı';
  String _userEmail = 'user@example.com';
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = AuthService.user;
    if (user != null) {
      setState(() {
        _userName = user['username'] ?? 'Kullanıcı Adı';
        _userEmail = user['email'] ?? 'user@example.com';
        _nameController.text = _userName;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showChangeProfileImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profil Fotoğrafını Değiştir'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Kameradan Çek'),
                onTap: () {
                  Navigator.of(context).pop();
                  _changeProfileImage('camera');
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galeriden Seç'),
                onTap: () {
                  Navigator.of(context).pop();
                  _changeProfileImage('gallery');
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Varsayılan Fotoğraf'),
                onTap: () {
                  Navigator.of(context).pop();
                  _changeProfileImage('default');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('İptal'),
            ),
          ],
        );
      },
    );
  }

  void _changeProfileImage(String source) async {
    final ImagePicker picker = ImagePicker();
    XFile? image;

    switch (source) {
      case 'camera':
        image = await picker.pickImage(source: ImageSource.camera);
        break;
      case 'gallery':
        image = await picker.pickImage(source: ImageSource.gallery);
        break;
      case 'default':
        // Set to default image
        setState(() {
          _profileImagePath = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil fotoğrafı varsayılan olarak ayarlandı'),
          ),
        );
        return;
    }

    if (image != null) {
      try {
        final result = await AuthService.uploadProfilePhoto(image.path);

        if (result['success']) {
          setState(() {
            _profileImagePath = image!.path;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result['message'])));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result['message'])));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fotoğraf yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  void _showChangeNameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('İsim Değiştir'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Yeni İsim',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('İsim boş olamaz!')));
                  return;
                }

                Navigator.of(context).pop();

                final result = await AuthService.updateProfile(
                  _nameController.text,
                  _userEmail,
                );

                if (result['success']) {
                  setState(() {
                    _userName = _nameController.text;
                  });
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result['message'])));
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result['message'])));
                }
              },
              child: Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Şifre Değiştir'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mevcut Şifre',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre Tekrar',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _currentPasswordController.clear();
                _newPasswordController.clear();
                _confirmPasswordController.clear();
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_currentPasswordController.text.isEmpty ||
                    _newPasswordController.text.isEmpty ||
                    _confirmPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tüm alanları doldurun!')),
                  );
                  return;
                }

                if (_newPasswordController.text !=
                    _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Yeni şifreler eşleşmiyor!')),
                  );
                  return;
                }

                if (_newPasswordController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Şifre en az 6 karakter olmalı!')),
                  );
                  return;
                }

                Navigator.of(context).pop();

                final result = await AuthService.changePassword(
                  _currentPasswordController.text,
                  _newPasswordController.text,
                );

                _currentPasswordController.clear();
                _newPasswordController.clear();
                _confirmPasswordController.clear();

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(result['message'])));
              },
              child: Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Çıkış Yap'),
          content: Text('Çıkış yapmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();

                AuthService.logout();

                // Use callback if provided, otherwise navigate to login
                if (widget.onLogout != null) {
                  widget.onLogout!();
                } else {
                  // Navigate to login page and clear all previous routes
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => LoginRegisterPage(),
                    ),
                    (route) => false,
                  );
                }

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Çıkış yapıldı')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.blueGrey.shade900,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Profil Fotoğrafı Bölümü
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage:
                              _profileImagePath != null
                                  ? FileImage(File(_profileImagePath!))
                                  : null,
                          child:
                              _profileImagePath == null
                                  ? Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.grey.shade600,
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.camera_alt, color: Colors.white),
                              onPressed: _showChangeProfileImageDialog,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      _userName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Profil Seçenekleri
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person, color: Colors.blue),
                      title: Text('İsim Değiştir'),
                      subtitle: Text('Kullanıcı adınızı güncelleyin'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: _showChangeNameDialog,
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.lock, color: Colors.orange),
                      title: Text('Şifre Değiştir'),
                      subtitle: Text('Hesap güvenliğinizi koruyun'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: _showChangePasswordDialog,
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.photo_camera, color: Colors.green),
                      title: Text('Profil Fotoğrafı'),
                      subtitle: Text('Fotoğrafınızı değiştirin'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: _showChangeProfileImageDialog,
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.settings, color: Colors.grey),
                      title: Text('Ayarlar'),
                      subtitle: Text('Uygulama ayarları'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ayarlar sayfası yakında gelecek'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Çıkış Yap Butonu
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _showLogoutDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text(
                        'Çıkış Yap',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Uygulama Bilgileri
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'FilMix',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Versiyon 1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
