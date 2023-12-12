// user_provider
import 'package:flutter/material.dart';
import 'store.dart'; // Import your existing StoreItem class

class UserProvider extends ChangeNotifier {
  StoreItem? _selectedOwnedItem;

  UserProvider() {
    _selectedOwnedItem = ownedItems.isNotEmpty ? ownedItems[0] : null;
  }

  StoreItem? get selectedOwnedItem => _selectedOwnedItem;

  set selectedOwnedItem(StoreItem? item) {
    _selectedOwnedItem = item;
    notifyListeners();
  }
}
