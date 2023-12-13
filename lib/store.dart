//store.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:provider/provider.dart';
import 'user_provider.dart';

// TODO: Make store page persistant (resets on going back)
=======

>>>>>>> adc6368042e710b50441c830cbf661c66190a758
class StoreItem {
  final String name;
  final int sellingPoints;
  bool isOwned;
  final String image;

  StoreItem({
    required this.name,
    required this.sellingPoints,
    this.isOwned = false,
    required this.image,
  });
}

class StorePage extends StatefulWidget {
  double overallScore;
  final void Function(double) updateOverallScore;
  final GlobalKey<StorePageState> storePageKey;

<<<<<<< HEAD
  StorePage({
=======

    StorePage({super.key, 
>>>>>>> adc6368042e710b50441c830cbf661c66190a758
    required this.overallScore,
    required this.updateOverallScore,
    required this.storePageKey,
  });

  @override
  StorePageState createState() => StorePageState();
}

List<StoreItem> storeItems = [
  StoreItem(
    name: 'Orange Fancy Cat',
    sellingPoints: 5,
    image: 'assets/avatars/cute_cat.png',
  ),
  StoreItem(
    name: 'Wizard Lizard',
    sellingPoints: 2,
    image: 'assets/avatars/wizard_lizard.png',
  ),
  StoreItem(
    name: 'Nerd Fairy',
    sellingPoints: 1,
    image: 'assets/avatars/nerd_fairy.png',
  ),
  StoreItem(
    name: 'Jeju Platypus',
    sellingPoints: 1,
    image: 'assets/avatars/vacation_platypus.png',
  ),
  // Add more items as needed
];

List<StoreItem> ownedItems = [
  StoreItem(
    name: 'Pet Rock',
    sellingPoints: 0,
    image: 'assets/avatars/pet_rock.png',
  ),
  // Add items that the user already owns
];

StoreItem selectedOwnedItem = ownedItems[0];

class StorePageState extends State<StorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  void _purchaseItem(StoreItem item) {
    // Show a confirmation dialog before the purchase
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Purchase'),
          content: Column(
            children: [
              Image.asset(
                  item.image), // Display the image in the confirmation dialog
              Text('Do you want to purchase ${item.name}?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Close the confirmation dialog
                Navigator.pop(context);
                // Proceed with the purchase
                _completePurchase(item);
              },
              child: const Text('Purchase'),
            ),
          ],
        );
      },
    );
  }

  void _completePurchase(StoreItem item) {
    if (widget.overallScore >= item.sellingPoints) {
      // Deduct sellingPoints from overallScore
      widget.overallScore -= item.sellingPoints;

      widget.updateOverallScore(widget.overallScore);
      _selectOwnedItem(item);
      Provider.of<UserProvider>(context, listen: false).selectedOwnedItem =
          item;

      // Show a confirmation dialog for successful purchase
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Purchase Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                    item.image), // Display the image in the success dialog
                Text('Item ${item.name} purchased!'),
                const SizedBox(height: 10),
                Text('Remaining points: ${widget.overallScore}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      // Update isOwned property to true
      setState(() {
        item.isOwned = true;
        ownedItems.add(item);
        if (kDebugMode) {
          print(
            'Item ${item.name} purchased! Remaining points: ${widget.overallScore}');
        }
      });

      // Remove the purchased item from the storeItems list
      setState(() {
        storeItems.remove(item);
      });
    } else {
      // Show a message that there are not enough points
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Insufficient Points'),
            content:
                Text('You do not have enough points to purchase ${item.name}. Keep completing tasks on time to earn more points!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Score'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Purchase'),
            Tab(text: 'Owned'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Purchase
              ListView.builder(
                itemCount: storeItems.length,
                itemBuilder: (context, index) {
                  final item = storeItems[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('Cost: ${item.sellingPoints} points'),
                    onTap: () {
                      _purchaseItem(item);
                    },
                    leading: Image.asset(item.image),
                    trailing: index == 0
                        ? Text(
                            'Total Points: ${widget.overallScore.toString()}')
                        : null,
                  );
                },
              ),

              // Tab 2: Owned
              ListView.builder(
                itemCount: ownedItems.length,
                itemBuilder: (context, index) {
                  final item = ownedItems[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: const Text('Owned'),
                    leading: GestureDetector(
                      onTap: () {
                        _selectOwnedItem(item);
                      },
                      child: Container(
                        width: 48.0,
                        height: 48.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectedOwnedItem == item
                              ? const Color.fromARGB(255, 218, 218, 218)
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Image.asset(
                            item.image,
                            width: 40.0, // Adjust the size of the image
                            height: 40.0,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: Container(
              width: 56.0,
              height: 56.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 218, 218, 218),
              ),
              child: Center(
                child: Image.asset(
                        selectedOwnedItem.image,
                        width: 96.0,
                        height: 96.0,
                      )
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 56.0,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop(); // Use pop instead of push
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectOwnedItem(StoreItem item) {
    setState(() {
      selectedOwnedItem = item;
    });
  }
}
