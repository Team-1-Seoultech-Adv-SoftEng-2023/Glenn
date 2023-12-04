import 'package:flutter/material.dart';

class StoreItem {
  final String name;
  final int sellingPoints;
  bool isOwned;

  StoreItem(
      {required this.name, required this.sellingPoints, this.isOwned = false});
}

class StorePage extends StatefulWidget {
  double overallScore;
  final void Function(double) updateOverallScore;
  StorePage({required this.overallScore, required this.updateOverallScore});

  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<StoreItem> storeItems = [
    StoreItem(name: 'Cap', sellingPoints: 5),
    StoreItem(name: 'Sun glasses', sellingPoints: 2),
    StoreItem(name: 'Scarf', sellingPoints: 1),
    StoreItem(name: 'Gloves', sellingPoints: 1),
    // Add more items as needed
  ];

  List<StoreItem> ownedItems = [
    // Add items that the user already owns
  ];

  void _purchaseItem(StoreItem item) {
    // Show a confirmation dialog before the purchase
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Purchase'),
          content: Text('Do you want to purchase ${item.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Close the confirmation dialog
                Navigator.pop(context);
                // Proceed with the purchase
                _completePurchase(item);
              },
              child: Text('Purchase'),
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

      // Show a confirmation dialog for successful purchase
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Purchase Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Item ${item.name} purchased!'),
                SizedBox(height: 10),
                Text('Remaining points: ${widget.overallScore}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      // Update isOwned property to true
      setState(() {
        item.isOwned = true;
        // TODO: Implement additional logic for item purchase (e.g., update user inventory)
        // You may want to navigate to a success page or perform other actions
        ownedItems.add(item);
        print(
            'Item ${item.name} purchased! Remaining points: ${widget.overallScore}');
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
            title: Text('Insufficient Points'),
            content:
                Text('You do not have enough points to purchase ${item.name}.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
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
        title: Text('Score'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Purchase'),
            Tab(text: 'Owned'),
          ],
        ),
      ),
      body: TabBarView(
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
                onTap: () => _purchaseItem(item),
                trailing: index == 0
                    ? Text('Total Points: ${widget.overallScore.toString()}')
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
                subtitle: Text('Owned'),
              );
            },
          ),
        ],
      ),
    );
  }
}
