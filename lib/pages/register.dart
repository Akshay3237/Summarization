import 'package:flutter/material.dart';
import 'package:textsummarize/models/Pair.dart';
import 'package:textsummarize/services/IUserService.dart';
import '../dependencies/dependencies.dart';
import '../models/User.dart';
import '../services/IAuthenticateService.dart';
import 'home.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Initialize your AuthService instance
  final Iauthenticateservice authService =Injection.getInstance<Iauthenticateservice>(Iauthenticateservice.typeName, true);
  final IUserService userService =Injection.getInstance<IUserService>(IUserService.typeName, true);

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Register method

  void _register() async {
    if (_formKey.currentState!.validate()) {
      // Extract form data
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String fullName = _fullNameController.text.trim();

      // Step 1: Attempt to register the user with FirebaseAuth
      var registrationResult = await authService.register(email, password);

      // Check if registration was successful
      if (registrationResult.first) {
        // Step 2: After registration, log the user in immediately
        var loginResult = await authService.login(email, password);

        // Check if login was successful
        if (loginResult.first) {
          // Step 3: Once logged in, save additional user data to Firestore
            User user=new User(fullname: fullName,email: email);

            Pair<bool,Object> result= await userService.save(user);
            // Step 4: Navigate to home page

            if(result.first){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(), // Change HomePage with your actual homepage
                ),
              );
            }
            else{
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Login Error: ${result.second.toString()}")),
              );
            }
        } else {
          // Handle login failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login Error: ${loginResult.second.toString()}")),
          );
        }
      } else {
        // Handle registration failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration Error: ${registrationResult.second.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        automaticallyImplyLeading: false, // Disable back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Login here',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
