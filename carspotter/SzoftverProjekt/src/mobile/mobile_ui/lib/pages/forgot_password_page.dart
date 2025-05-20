import 'package:flutter/material.dart';
import 'package:mobile_ui/components/my_button.dart';
import 'package:mobile_ui/components/my_text_field.dart';
import 'package:mobile_ui/pages/home_page.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  // text editing controller
  final emailController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
          
              // key logo
              const Icon(
                Icons.key,
                size: 100,
              ),
          
              const SizedBox(height: 50),
              
              // email
              MyTextField(
                // focusNode: myFocusNode,
                controller: emailController,
                hintText: 'Enter your email',
                obscureText: false
              ),

              const SizedBox(height: 50),

              // confirm button
              MyButton(
                text: 'Confirm',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                }
              ),
            ],
          ),
        ),
      )
    );
  }
}