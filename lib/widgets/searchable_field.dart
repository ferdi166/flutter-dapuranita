import 'package:flutter/material.dart';

class SearchableField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final VoidCallback onTap;
  final bool enabled;

  const SearchableField({
    Key? key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(10),
          color: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label seperti TextFormField
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: enabled ? Colors.blueAccent : Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            // Content
            Row(
              children: [
                Icon(
                  icon,
                  color: enabled ? Colors.blueAccent : Colors.grey,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value ?? 'Pilih $label',
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null
                          ? Colors.black87
                          : (enabled ? Colors.grey[600] : Colors.grey[400]),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: enabled ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
