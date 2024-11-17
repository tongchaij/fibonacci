import 'package:flutter/material.dart';

class Item {
  int index;
  int number;
  int type;

  Item(this.index, this.number, this.type);
}

// Map<type, IconData>
const Map<int, IconData> iconMap = {
  0: Icons.crop_square,
  1: Icons.circle,
  2: Icons.close,
};

Map<int, List<Item>> selectedLists = {
  0: [],
  1: [],
  2: [],
};
