import 'dart:math';

import 'item.dart';

class Service {
  // Simulate fetching data (e.g., from a remote API or database)
  List<int> generateFibonacci(int need) {
    List<int> fibonacciList = [0, 1];

    for (int i = 2; i < need; i++) {
      int nextFib = fibonacciList[i - 1] + fibonacciList[i - 2];
      fibonacciList.add(nextFib); // Convert each Fibonacci number to a string
    }

    return fibonacciList; // Return a List<String>
  }

  Future<List<Item>> generateItems(int need) async {
    await Future.delayed(Duration(seconds: 1)); // Simulate a delay

    List<int> fibs = generateFibonacci(need);
    List<Item> fibonacciList = [];
    Random random = Random();

    for (int i = 0; i < fibs.length; i++) {
      int randomType = random.nextInt(iconMap.length);
      Item nextFib = Item(i, fibs[i], randomType);
      fibonacciList.add(nextFib);
    }

    return fibonacciList; // Return a List<String>
  }

  addToSelectedList(Item item) {
    List<Item> list = selectedLists[item.type]!;
    if (list.indexOf(item)<0) {
      int index = list.indexWhere((element) => element.index > item.index);

      if (index == -1) {
        // If the item is greater than all existing items, add it to the end
        list.add(item);
      } else {
        // Otherwise, insert the new item at the correct position
        list.insert(index, item);
      }
    }
  }

  removeFromSelectedList(Item item) {
    List<Item> list = selectedLists[item.type]!;
    list.remove(item);
  }

  int indexOf(Item item) {
    List<Item> list = selectedLists[item.type]!;
    return list.indexOf(item);
  }

}