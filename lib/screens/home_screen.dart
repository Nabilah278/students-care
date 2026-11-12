import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:students_care/screens/account_screen.dart';
import 'package:students_care/screens/reminders_screen.dart';
import 'package:students_care/screens/summary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _items = ['Student Support Item 1', 'Student Support Item 2'];
  
  final TextEditingController _addController = TextEditingController();
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _addController.dispose();
    _editController.dispose();
    super.dispose();
  }

  // Load saved items from local storage
  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final savedItems = prefs.getStringList('student_care_items');
    if (savedItems != null) {
      setState(() {
        _items = savedItems;
      });
    }
  }


  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('student_care_items', _items);
  }

  void _addItem() {
    if (_addController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an item name!')),
      );
      return;
    }
    setState(() {
      _items.add(_addController.text.trim());
      _addController.clear();
    });
    _saveItems();
  }

  void _showEditDialog(int index) {
    _editController.text = _items[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: TextField(
          controller: _editController,
          decoration: const InputDecoration(labelText: 'Update Details'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_editController.text.trim().isNotEmpty) {
                setState(() {
                  _items[index] = _editController.text.trim();
                });
                _saveItems();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _saveItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students Care'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Account',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen(studentName: 'Demo Student')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Reminders',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RemindersScreen(
                    title: 'Active Reminders',
                    reminders: _items,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.assessment),
            tooltip: 'Summary',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SummaryScreen(
                    title: 'Tasks Summary',
                    message: 'You currently have ${_items.length} items logged.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    decoration: const InputDecoration(
                      hintText: 'Add new item...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addItem,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('No items found.'))
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(_items[index]),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // EDIT BUTTON
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showEditDialog(index),
                                ),
                                // DELETE BUTTON
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteItem(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
