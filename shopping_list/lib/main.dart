
import 'package:flutter/material.dart';

void main() {
  runApp(const ShoppingApp());
}

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green),
      home: const HomeScreen(title: 'Shopping List'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> items = ['Milk', 'Bread', 'Rice'];
  final Set<String> boughtItems = {};
  final TextEditingController controller = TextEditingController();

  int get remainingItems => items.length - boughtItems.length;

  void addItem() {
    final text = controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type an item first')),
      );
      return;
    }

    final alreadyExists = items.any(
          (item) => item.toLowerCase() == text.toLowerCase(),
    );

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$text is already on the list')),
      );
      return;
    }

    setState(() {
      items.add(text);
    });

    controller.clear();
  }

  void deleteItem(int index) {
    final removedItem = items[index];

    setState(() {
      boughtItems.remove(removedItem);
      items.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$removedItem removed')),
    );
  }

  void toggleBought(String item, bool? isBought) {
    setState(() {
      if (isBought == true) {
        boughtItems.add(item);
      } else {
        boughtItems.remove(item);
      }
    });
  }

  void clearBoughtItems() {
    setState(() {
      items.removeWhere((item) => boughtItems.contains(item));
      boughtItems.clear();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.title} ($remainingItems remaining)',
        ),
        actions: [
          IconButton(
            tooltip: 'Clear bought items',
            icon: const Icon(Icons.cleaning_services),
            onPressed: boughtItems.isEmpty ? null : clearBoughtItems,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter shopping item',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: addItem,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total items: ${items.length}'),
                Text('Bought: ${boughtItems.length}'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isBought = boughtItems.contains(item);

                return ListTile(
                  leading: Checkbox(
                    value: isBought,
                    onChanged: (value) => toggleBought(item, value),
                  ),
                  title: Text(
                    item,
                    style: TextStyle(
                      decoration: isBought
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: isBought ? Colors.grey : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    tooltip: 'Delete item',
                    onPressed: () => deleteItem(index),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                boughtItems.isEmpty ? null : clearBoughtItems,
                icon: const Icon(Icons.cleaning_services),
                label: const Text('Clear Bought Items'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
