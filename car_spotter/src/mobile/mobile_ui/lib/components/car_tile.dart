import 'package:flutter/material.dart';
import 'package:mobile_ui/models/car.dart';

class CarTile extends StatelessWidget {
  final Car car;
  final void Function() onTap;

  const CarTile({
    super.key,
    required this.car,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Car image and name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Car image
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        car.imagePath, // URL for the image
                        height: 100,
                        width: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.directions_car, size: 100),
                      ),
                    ),
                  ),

                  // Car name
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        children: [
                          Text(
                            car.name,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Car details
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car.fuelType,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        Text(
                          "${car.kilometers.toString()} Km",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        Text(
                          "Manufactured in ${car.year}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            "${car.price.toString()} €",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}