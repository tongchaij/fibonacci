import 'package:flutter/material.dart';
import 'service.dart';
import 'item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fibonacci',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Fibonacci'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // constant
  final int MAX_ITEM_COUNT = 40;
  final double ITEM_HEIGHT = 56.0;

  // main list
  int _mainSelectedIndex = -1;
  late Future<List<Item>> _mainList;
  final ScrollController _mainScrollController = ScrollController();
  final GlobalKey _mainListViewKey = GlobalKey();

  // selected sub list
  int _subSelectedIndex = -1;
  final ScrollController _subScrollController = ScrollController();
  final GlobalKey _subListViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _mainList = Service().generateItems(MAX_ITEM_COUNT); // Call the service to fetch items
  }

  bool isItemVisible(int uiIndex, ScrollController scrollController, GlobalKey listViewKey) {
    if (!scrollController.hasClients) return false;

    final RenderBox renderBox = listViewKey.currentContext?.findRenderObject() as RenderBox;
    final position = scrollController.position;

    final double itemPositionStart = uiIndex * ITEM_HEIGHT;
    final double itemPositionEnd = itemPositionStart + ITEM_HEIGHT;

    return itemPositionStart >= position.pixels && itemPositionEnd <= position.pixels + renderBox.size.height;
  }

  void _scrollToSelectedItem(int uiIndex, ScrollController scrollController) {
    // Calculate the position to scroll to
    final double offset = ITEM_HEIGHT * uiIndex; // Scroll offset

    // Use the controller to scroll to the position of the selected item
    scrollController.animateTo(
        offset,
        duration: Duration(milliseconds: 500), // Animation duration
        curve: Curves.easeInOut, // Scroll animation curve
    );
  }

  void _addToMainList(Item item) {
    _mainList.then((list) {
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
    }).catchError((e) {
      print('Error: $e');
    });
  }

  void _removeFromMainList(Item item) {
    _mainList.then((list) {
      list.remove(item);
    }).catchError((e) {
      print('Error: $e');
    });
  }

  Future<int> _indexOf(Item item) => _mainList.then((list) {
      return list.indexOf(item);
  }).catchError((e) {
      print('Error: $e');
  });

  void _showBottomSheet(BuildContext context, Item _item) {

    ListView listView = ListView.builder(
        key: _subListViewKey,
        controller: _subScrollController,
        itemCount: selectedLists[_item.type]?.length,
        itemBuilder: (context, index) {
          final item = selectedLists[_item.type]?[index];
          bool isSelected = item!.index == _subSelectedIndex;
          return Container(
            height: ITEM_HEIGHT,
            color: isSelected ? Colors.green : Colors.transparent,
            child: ListTile(
              title: Text("Number: " + item.number.toString()),
              subtitle: Text("Index: " + item.index.toString()),
              trailing: Icon(iconMap[item.type], size: 20),
              onTap: () {
                // Handle tap event for each list item
                Navigator.pop(context); // Close BottomSheet
                setState(() {
                  Service().removeFromSelectedList(item);
                  _addToMainList(item);
                  _mainSelectedIndex = item.index;
                });

                _indexOf(item).then((listIndex) {
                  Future.delayed(Duration(milliseconds: 100), ()
                  {
                    if (!isItemVisible(listIndex, _mainScrollController, _mainListViewKey)) {
                      _scrollToSelectedItem(listIndex, _mainScrollController);
                    }
                  });
                });

              }
            ),
          );
        }
    );

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return listView;
      }
    ).then((_) {
      _scrollToSelectedItem(0, _subScrollController);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Item>>(
        future: _mainList,
        builder: (context, snapshot) {
          // Check the state of the Future
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading indicator
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Error handling
          } else if (snapshot.hasData) {
            // Display the list when data is available
            return ListView.builder(
              key: _mainListViewKey,
              controller: _mainScrollController,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Item item = snapshot.data![index];
                bool isSelected = item.index == _mainSelectedIndex;
                return Container(
                    height: ITEM_HEIGHT,
                    color: isSelected ? Colors.red : Colors.transparent,
                    child:ListTile(
                      title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space out the widgets
                          children: [
                            Text("Index: "+item.index.toString()+", Number: "+item.number.toString()),
                            Icon(iconMap[item.type], size:20)
                          ]
                      ),
                      onTap: () {
                        setState(() {
                          _mainSelectedIndex = -1;
                          _removeFromMainList(item);
                          Service().addToSelectedList(item);
                          _subSelectedIndex = item.index;
                        });

                        _showBottomSheet(context, item);

                        Future.delayed(Duration(milliseconds: 100), ()
                        {
                          int listIndex = Service().indexOf(item);
                          if (!isItemVisible(listIndex, _subScrollController, _subListViewKey)) {
                            _scrollToSelectedItem(listIndex, _subScrollController);
                          }
                        });
                      }
                    )
                );
              },
            );
          } else {
            return Center(child: Text('No data available')); // No data
          }
        },
      ),
    );
  }
}
