// store_state.dart
import 'package:flutter/material.dart';
import 'store.dart';

class StoreState extends ChangeNotifier {
  double overallScore;
  List<StoreItem> storeItems;
  List<StoreItem> ownedItems;

  StoreState({
    required this.overallScore,
    required this.storeItems,
    required this.ownedItems,
  });

  void updateOverallScore(double newScore) {
    overallScore = newScore;
    notifyListeners();
  }

  void purchaseItem(StoreItem item) {
    // Your purchase logic here
    // ...
    notifyListeners();
  }

  // Add more methods as needed
}
