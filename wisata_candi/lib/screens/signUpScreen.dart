import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:wisata_candi/screens/SignInScreen.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SignUpScreen extends StatefulWidget 
{
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
{
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorText='';
  bool _obscurePassword = true;

  //TODO: 1 membuat fungsi _signUp
  void _signUp() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String name = _nameController.text.trim();
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

      if(password.length < 8 || 
        !password.contains(RegExp(r'[A-Z]')) || 
        !password.contains(RegExp(r'[a-z]')) || 
        !password.contains(RegExp(r'[0-9]')) || 
        !password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')))
      {
        setState(() {
          _errorText = 'Minimal 8 Karakter, kombinasi [A-Z], [a-z], [0-9],[!@#\$%^&*(),.?":{}|<>]';
        });
        return;
      }
      //TODO: 3 jika name,username, password tidak kosng lakukan enskripsi
      if(name.isNotEmpty && username.isNotEmpty && password.isNotEmpty)
      {
        final encrypt.Key key = encrypt.Key.fromLength(32);
        final iv = encrypt.IV.fromLength(16);

        final encrypter = encrypt.Encrypter(encrypt.AES(key));
        final encryptedName = encrypter.encrypt(name, iv: iv);
        final encryptedUsername = encrypter.encrypt(username, iv: iv);
        final encryptedPassword = encrypter.encrypt(password, iv: iv);

       //simpan data pengguna di SharedPreferences
        prefs.setString('fulname', encryptedName.base64);
        prefs.setString('username', encryptedUsername.base64);
        prefs.setString('password', encryptedPassword.base64);
        prefs.setString('key', key.base64);
        prefs.setString('iv', iv.base64);
       }

      //buat navigasi ke signinscreen
      Navigator.pushReplacementNamed(context, '/signin');
  }

  //TODO: 2 membuat fungsi dispose
  @override
  void dispose ()
  {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar (
        title: const Text('Sign Up'),
      ),
      body: Center (
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Masukkan Nama Anda',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Masukkan Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Masukkan Password',
                  errorText: _errorText.isNotEmpty ? _errorText: null,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                     onPressed: () {
                      setState(() {
                        _obscurePassword =! _obscurePassword;
                      });
                     },
                     icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                     ),
                  ),
                ),
                obscureText:_obscurePassword,
                ),
                 const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signUp,
                  child: Text('Sign Up'),
              ),
            ],
          )),
          ),
        ),
      ),
    );
  }
}