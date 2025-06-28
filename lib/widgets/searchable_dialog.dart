import 'package:flutter/material.dart';

class SearchableDialog<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) displayText;
  final String searchHint;
  final String? currentValue;
  final String? Function(T) compareValue;

  const SearchableDialog({
    Key? key,
    required this.title,
    required this.items,
    required this.displayText,
    required this.searchHint,
    this.currentValue,
    required this.compareValue,
  }) : super(key: key);

  @override
  State<SearchableDialog<T>> createState() => _SearchableDialogState<T>();
}

class _SearchableDialogState<T> extends State<SearchableDialog<T>> {
  final TextEditingController searchController = TextEditingController();
  List<T> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    searchController.addListener(_filterItems);
  }

  void _filterItems() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredItems = widget.items.where((item) {
        return widget.displayText(item).toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(child: Text('Tidak ada data ditemukan'))
                  : ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final isSelected =
                            widget.compareValue(item) == widget.currentValue;

                        return ListTile(
                          title: Text(widget.displayText(item)),
                          selected: isSelected,
                          selectedTileColor: Colors.blue.withOpacity(0.1),
                          onTap: () => Navigator.pop(context, item),
                          trailing: isSelected
                              ? Icon(Icons.check, color: Colors.blue)
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
