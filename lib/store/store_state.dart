// store/store_state.dart
import 'package:flutter/material.dart';
import 'store_item.dart';

class StoreState extends ChangeNotifier {
  double overallScore;
  List<StoreItem> storeItems;
  List<StoreItem> ownedItems;
  StoreItem? _selectedOwnedItem;

  StoreState({
    required this.overallScore,
    required this.storeItems,
    required this.ownedItems,
  });

  StoreItem? get selectedOwnedItem => _selectedOwnedItem;

  void updateOverallScore(double newScore) {
    overallScore = newScore;
    // notifyListeners();
  }

  void purchaseItem(StoreItem item) {
    // Your purchase logic here
    // ...
    // notifyListeners();
  }

  void selectOwnedItem(StoreItem? item) {
    _selectedOwnedItem = item;
    notifyListeners();
  }

  void removeStoreItem(StoreItem item) {
    storeItems.remove(item);
    notifyListeners();
  }

  // Add more methods as needed
}
