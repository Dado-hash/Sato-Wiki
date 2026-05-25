import 'package:flutter/material.dart';

class FilterChipBar<T> extends StatelessWidget {
  const FilterChipBar({
    required this.items,
    required this.selectedItem,
    required this.labelFor,
    required this.onSelected,
    super.key,
  });

  final List<T> items;
  final T selectedItem;
  final String Function(T item) labelFor;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(labelFor(item)),
                selected: item == selectedItem,
                showCheckmark: false,
                onSelected: (_) => onSelected(item),
              ),
            ),
        ],
      ),
    );
  }
}
