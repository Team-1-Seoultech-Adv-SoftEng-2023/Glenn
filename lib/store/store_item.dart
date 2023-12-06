// store/store_item.dart
class StoreItem {
  final String name;
  final int sellingPoints;
  bool isOwned;
  final String image; // Add an image property

  StoreItem({
    required this.name,
    required this.sellingPoints,
    this.isOwned = false,
    required this.image,
  });
}


  List<StoreItem> defaultStoreItems = [
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

  List<StoreItem> defaultOwnedItems = [
    StoreItem(
      name: 'Pet Rock',
      sellingPoints: 0,
      image: 'assets/avatars/pet_rock.png',
    ),
    // Add items that the user already owns
  ];