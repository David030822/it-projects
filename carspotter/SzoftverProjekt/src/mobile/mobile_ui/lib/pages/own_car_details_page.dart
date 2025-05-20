import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_ui/components/custom_button.dart';
import 'package:mobile_ui/models/own_car.dart';
import 'package:mobile_ui/pages/notes_page.dart';

// ignore: must_be_immutable
class OwnCarDetailsPage extends StatelessWidget {
  OwnCar ownCar;
  OwnCarDetailsPage({super.key, required this.ownCar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    ownCar.imagePath,
                    height: 200,
                    width: 300,
                  ),
                ),
          
                const SizedBox(height: 20),
          
                Text(
                  'Car Details',
                  style: GoogleFonts.dmSerifText(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  )
                ),
          
                const SizedBox(height: 15),
          
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    "Model: ${ownCar.name}",
                    style: GoogleFonts.dmSerifText(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    )
                  ),
                ),
          
                const SizedBox(height: 15),
          
                Text(
                  "Fuel type: ${ownCar.fuelType}",
                  style: GoogleFonts.dmSerifText(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  )
                ),
          
                const SizedBox(height: 15),
          
                Text(
                  "Kilometers: ${ownCar.kilometers.toString()}",
                  style: GoogleFonts.dmSerifText(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  )
                ),
          
                const SizedBox(height: 15),
          
                Text(
                  "Manufacture year: ${ownCar.year.toString()}",
                  style: GoogleFonts.dmSerifText(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  )
                ),
          
                const SizedBox(height: 15),
          
                Text(
                  "Chassis type: ${ownCar.chassis}",
                  style: GoogleFonts.dmSerifText(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  )
                ),
          
                const SizedBox(height: 15),
          
                Text(
                  "Gearbox: ${ownCar.gearbox}",
                  style: GoogleFonts.dmSerifText(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  )
                ),
          
                const SizedBox(height: 15),
          
                Text(
                  "Engine size: ${ownCar.engineSize.toString()} cm³",
                  style: GoogleFonts.dmSerifText(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  )
                ),
          
                const SizedBox(height: 15),
          
                Text(
                  "Horsepower: ${ownCar.horsepower.toString()}",
                  style: GoogleFonts.dmSerifText(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  )
                ),
          
                const SizedBox(height: 15),
          
                Text(
                  "Bought for: ${ownCar.buyPrice.toString()}",
                  style: GoogleFonts.dmSerifText(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  )
                ),
          
                const SizedBox(height: 15),
          
                Text(
                  "Spent on: ${ownCar.spent.toString()}",
                  style: GoogleFonts.dmSerifText(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  )
                ),
          
                const SizedBox(height: 15),

                Text(
                  "Selling for: ${ownCar.price.toString()}",
                  style: GoogleFonts.dmSerifText(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  )
                ),

                const SizedBox(height: 15),
          
                Text(
                  "Sold for: ${ownCar.sellPrice.toString()}",
                  style: GoogleFonts.dmSerifText(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  )
                ),
          
                const SizedBox(height: 20),
                
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: CustomButton(
                    color: Theme.of(context).colorScheme.tertiary,
                    textColor: Theme.of(context).colorScheme.outline,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotesPage(),
                        ),
                      );
                    },
                    label: '+ Add Notes',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}