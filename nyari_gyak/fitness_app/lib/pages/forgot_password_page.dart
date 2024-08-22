import 'package:fitness_app/components/my_button.dart';
import 'package:fitness_app/components/my_text_field.dart';
import 'package:fitness_app/pages/home_page.dart';
import 'package:flutter/material.dart';

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
              SizedBox(height: 50),
          
              // key logo
              Icon(
                Icons.key,
                size: 100,
              ),
          
              SizedBox(height: 50),
              
              // email
              MyTextField(
                controller: emailController,
                hintText: 'Enter your email',
                obscureText: false
              ),

              SizedBox(height: 50),

              // confirm button
              MyButton(
                text: 'Confirm',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
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