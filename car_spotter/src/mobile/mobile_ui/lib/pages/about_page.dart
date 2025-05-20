import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_ui/components/my_drawer.dart';
import 'package:url_launcher/url_launcher.dart';


class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        // backgroundColor: Colors.transparent,
        // title: Text(
        //   'About Page',
        //   style: GoogleFonts.dmSerifText(
        //     fontSize: 28,
        //     color: Theme.of(context).colorScheme.inversePrimary,
        //   ),
        // ),
      ),
      drawer: const MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'About the App:',
                style: GoogleFonts.dmSerifText(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This application processes data from autovit.ro to provide insights and statistics for car dealers and buyers. It offers functionalities to analyze car sales, track dealer activities, and make data-driven decisions.',
                style: GoogleFonts.roboto(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Developer Info:',
                style: GoogleFonts.dmSerifText(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This project is developed young developers, aiming to enhance decision-making for car enthusiasts and dealers through advanced data analytics.',
                style: GoogleFonts.roboto(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Contact:',
                style: GoogleFonts.dmSerifText(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'For any inquiries, reach us at:',
                style: GoogleFonts.roboto(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Email: support@developers.com',
                style: GoogleFonts.roboto(fontSize: 16),
              ),
              const SizedBox(height: 4),
               Text(
                'Autovit.ro website:',
                style: GoogleFonts.dmSerifText(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(  //opening the website
                onTap: () async {
                  const url = 'https://www.autovit.ro/';
                  try{
                    final Uri uri = Uri.parse(url);
                    if(await canLaunchUrl((uri))){
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(  //if cant open the website 
                      const SnackBar(content: Text('Could not open URL')),
                    );
                  }
                
                }catch(e) {
                    debugPrint('Error opening URL: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('An error occurred while opening the URL')),
                    );
                  }
                 
                },
                child: Text(
                  'www.autovit.ro',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    //color: Theme.of(context).colorScheme.primary,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Version:',
                style: GoogleFonts.dmSerifText(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1.0.0',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Developed with ❤️ by Developer Team',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
