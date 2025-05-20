import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_ui/components/my_button.dart';
import 'package:mobile_ui/components/my_text_field.dart';
import 'package:mobile_ui/pages/login_page.dart';
import 'package:mobile_ui/services/api_service.dart'; 

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final dealerNameController = TextEditingController();

  File? selectedImage; // To store the selected image
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker(); // Image picker instance

  // Handle user registration
  Future<void> handleRegister() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.registerUser(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        phone: phoneController.text,
        password: passwordController.text,
        dealerInventoryName: dealerNameController.text.isEmpty ? null : dealerNameController.text, // Optional field
        profileImage: selectedImage, // Optional field
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration successful: ${result['message']}")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Select image from gallery or camera
  Future<void> selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // or ImageSource.camera

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path); // Save the selected image file
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),

                      // Logo
                      const Icon(
                        Icons.app_registration,
                        size: 100,
                      ),

                      const SizedBox(height: 50),

                      // Welcome message
                      Text(
                        'Let\'s create an account for you!',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Input fields
                      MyTextField(
                        controller: firstNameController,
                        hintText: 'First Name',
                        obscureText: false,
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        controller: lastNameController,
                        hintText: 'Last Name',
                        obscureText: false,
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        controller: emailController,
                        hintText: 'Email',
                        obscureText: false,
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        controller: phoneController,
                        hintText: 'Phone',
                        obscureText: false,
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        controller: confirmPasswordController,
                        hintText: 'Confirm Password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 25),
                      MyTextField(
                        controller: dealerNameController,
                        hintText: 'Dealer name(optional)',
                        obscureText: false,
                      ),

                      const SizedBox(height: 25),

                      // Image picker button
                      ElevatedButton(
                        onPressed: selectImage,
                        child: Text(
                            selectedImage != null ? 'Change Image' : 'Upload Image'),
                      ),
                      if (selectedImage != null) ...[
                        const SizedBox(height: 10),
                        Image.file(
                          selectedImage!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ],

                      const SizedBox(height: 25),

                      // Register button or progress indicator
                      isLoading
                          ? const CircularProgressIndicator()
                          : MyButton(
                              text: 'Register Now',
                              onTap: handleRegister,
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
