import 'package:flutter/material.dart';
import 'package:mobile_ui/models/dealer.dart';
import 'package:mobile_ui/services/auth_service.dart';
import 'package:mobile_ui/services/api_service.dart';

class DealerTile extends StatefulWidget {
  final Dealer dealer;
  final void Function() onTap;
  final void Function() onButtonTap;

  const DealerTile({
    super.key,
    required this.dealer,
    required this.onTap,
    required this.onButtonTap
  });

  @override
  // ignore: library_private_types_in_public_api
  _DealerTileState createState() => _DealerTileState();
}

class _DealerTileState extends State<DealerTile> {
  bool isFavorited = false;
  int? userId; 

  @override
  void initState() {
    super.initState();
    _initializeUserId();
    isFavorited = widget.dealer.isFavorited;
  }

  Future<void> _initializeUserId() async {
    final token = await AuthService.getToken();
    final userIdFromToken = await AuthService.getUserIdFromToken(token);
    setState(() {
      userId = userIdFromToken;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // dealer logo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.dealer.imagePath,
                      height: 100,
                      width: 150,
                    ),
                  ),
                ),

                // name
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Column(
                      children: [
                        Text(
                            widget.dealer.name,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // location + active since
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.dealer.location,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Active since ${widget.dealer.activeSince}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ],
                  ),

                  // button to add to favorites
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        isFavorited = !isFavorited;
                      });

                      try {
                        await ApiService.toggleFavorite(userId!, widget.dealer.id, isFavorited);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isFavorited
                                ? '${widget.dealer.name} added to favorites'
                                : '${widget.dealer.name} removed from favorites'),
                          ),
                        );
                      } catch (e) {
                        // Handle error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update favorite status')),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: isFavorited ? Colors.red : Colors.white,
                      ),
                    ),
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
