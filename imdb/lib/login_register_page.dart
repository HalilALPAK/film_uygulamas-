import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginRegisterPage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginRegisterPage({super.key, this.onLoginSuccess});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login form controllers
  final TextEditingController _loginUsernameController =
      TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  // Register form controllers
  final TextEditingController _registerUsernameController =
      TextEditingController();
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _registerConfirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _showLoginPassword = false;
  bool _showRegisterPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _registerUsernameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loginUsernameController.text.isEmpty ||
        _loginPasswordController.text.isEmpty) {
      _showMessage('Kullanıcı adı ve şifre gereklidir!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.login(
        _loginUsernameController.text.trim(),
        _loginPasswordController.text,
      );

      if (result['success']) {
        _showMessage(result['message']);

        // Call the success callback or navigate
        if (widget.onLoginSuccess != null) {
          widget.onLoginSuccess!();
        } else {
          // Fallback: just pop the current page
          Navigator.pop(context);
        }
      } else {
        _showMessage(result['message']);
      }
    } catch (e) {
      _showMessage('Beklenmeyen hata: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _register() async {
    if (_registerUsernameController.text.isEmpty ||
        _registerEmailController.text.isEmpty ||
        _registerPasswordController.text.isEmpty) {
      _showMessage('Tüm alanları doldurunuz!');
      return;
    }

    if (_registerPasswordController.text !=
        _registerConfirmPasswordController.text) {
      _showMessage('Şifreler eşleşmiyor!');
      return;
    }

    if (_registerPasswordController.text.length < 6) {
      _showMessage('Şifre en az 6 karakter olmalıdır!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.register(
        _registerUsernameController.text.trim(),
        _registerEmailController.text.trim(),
        _registerPasswordController.text,
      );

      if (result['success']) {
        _showMessage(result['message']);
        _tabController.animateTo(0); // Switch to login tab
        _clearRegisterForm();
      } else {
        _showMessage(result['message']);
      }
    } catch (e) {
      _showMessage('Beklenmeyen hata: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearRegisterForm() {
    _registerUsernameController.clear();
    _registerEmailController.clear();
    _registerPasswordController.clear();
    _registerConfirmPasswordController.clear();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 3)),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 40),

          // Logo or App Name
          Center(
            child: Column(
              children: [
                Icon(Icons.movie, size: 80, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'FilMix',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Film dünyasına hoş geldiniz',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),

          SizedBox(height: 40),

          // Username field
          TextField(
            controller: _loginUsernameController,
            decoration: InputDecoration(
              labelText: 'Kullanıcı Adı veya Email',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          SizedBox(height: 16),

          // Password field
          TextField(
            controller: _loginPasswordController,
            obscureText: !_showLoginPassword,
            decoration: InputDecoration(
              labelText: 'Şifre',
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _showLoginPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _showLoginPassword = !_showLoginPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          SizedBox(height: 24),

          // Login button
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                      'Giriş Yap',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),

          SizedBox(height: 16),

          // Demo login button
          OutlinedButton(
            onPressed: () {
              _loginUsernameController.text = 'demo';
              _loginPasswordController.text = 'demo123';
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Demo Hesabı Kullan'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),

          Text(
            'Hesap Oluştur',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8),

          Text(
            'FilMix ailesine katılın',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 32),

          // Username field
          TextField(
            controller: _registerUsernameController,
            decoration: InputDecoration(
              labelText: 'Kullanıcı Adı',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          SizedBox(height: 16),

          // Email field
          TextField(
            controller: _registerEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          SizedBox(height: 16),

          // Password field
          TextField(
            controller: _registerPasswordController,
            obscureText: !_showRegisterPassword,
            decoration: InputDecoration(
              labelText: 'Şifre',
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _showRegisterPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _showRegisterPassword = !_showRegisterPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          SizedBox(height: 16),

          // Confirm password field
          TextField(
            controller: _registerConfirmPasswordController,
            obscureText: !_showConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Şifre Tekrar',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _showConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _showConfirmPassword = !_showConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          SizedBox(height: 24),

          // Register button
          ElevatedButton(
            onPressed: _isLoading ? null : _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                      'Kayıt Ol',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade700],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),

            // Tab bar
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.blueGrey.shade900,
                unselectedLabelColor: Colors.white,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                tabs: [Tab(text: 'Giriş Yap'), Tab(text: 'Kayıt Ol')],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildLoginForm(), _buildRegisterForm()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
