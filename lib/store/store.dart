// store/store.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'store_state.dart'; // Import the StoreState class
import 'store_item.dart';

// TODO: Make store page persistant (resets on going back)

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
  StoreItem? _selectedOwnedItem; // Add this line to declare the variable

  void _purchaseItem(StoreItem item) {
    // Show a confirmation dialog before the purchase
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Purchase'),
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
  final storeState = context.read<StoreState>();

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
              Image.asset(
                  item.image), // Display the image in the success dialog
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
    storeState.purchaseItem(item);

    // Remove the purchased item from the storeItems liststoreState.removeStoreItem(item);
    storeState.selectOwnedItem(
      storeState.ownedItems.isNotEmpty
          ? storeState.ownedItems[0]
          : null,
    );


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


  void _selectOwnedItem(StoreItem item) {
    setState(() {
      _selectedOwnedItem = item;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<StoreState>().selectOwnedItem(
      context.read<StoreState>().ownedItems.isNotEmpty
          ? context.read<StoreState>().ownedItems[0]
          : null,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StoreState(
        overallScore: widget.overallScore,
        storeItems: defaultStoreItems,
        ownedItems: defaultOwnedItems,
      ),
      child: Scaffold(
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
        body: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Purchase
                PurchaseTab(),

                // Tab 2: Owned
                OwnedTab(),
              ],
            ),
            Positioned(
              bottom: 16.0,
              left: 16.0,
              child: Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 218, 218, 218),
                ),
                child: Center(
                  child: context.watch<StoreState>().selectedOwnedItem != null
                      ? Image.asset(
                          context.watch<StoreState>().selectedOwnedItem!.image,
                          width: 96.0,
                          height: 96.0,
                        )
                      : SizedBox(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PurchaseTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<StoreState>(
      builder: (context, storeState, _) => ListView.builder(
        itemCount: storeState.storeItems.length,
        itemBuilder: (context, index) {
          final item = storeState.storeItems[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text('Cost: ${item.sellingPoints} points'),
            onTap: () => storeState.purchaseItem(item),
            leading: Image.asset(item.image),
            trailing: index == 0
                ? Text('Total Points: ${storeState.overallScore.toString()}')
                : null,
          );
        },
      ),
    );
  }
}

class OwnedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<StoreState>(
      builder: (context, storeState, _) => ListView.builder(
        itemCount: storeState.ownedItems.length,
        itemBuilder: (context, index) {
          final item = storeState.ownedItems[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text('Owned'),
            leading: GestureDetector(
              onTap: () => storeState.selectOwnedItem(item),
              child: Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: storeState.selectedOwnedItem == item
                      ? Color.fromARGB(255, 218, 218, 218)
                      : Colors.transparent,
                ),
                child: Center(
                  child: Image.asset(
                    item.image,
                    width: 40.0,
                    height: 40.0,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
