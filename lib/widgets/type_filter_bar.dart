import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/type_filter_provider.dart';
import '../utils/text_utils.dart';

/// Row of type chips: "All" + one chip per type found in the data.
class TypeFilterBar extends ConsumerWidget {
  const TypeFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = ref.watch(availableTypesProvider);
    final selected = ref.watch(typeFilterProvider);
    final notifier = ref.read(typeFilterProvider.notifier);

    return SizedBox(
      height: 52,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: selected == null,
                    onSelected: (_) => notifier.clearFilter(),
                  ),
                ),
                for (final type in types)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(capitalize(type)),
                      selected: selected == type,
                      onSelected: (_) => notifier.selectType(type),
                    ),
                  ),
              ],
            ),
          ),
          if (selected != null)
            IconButton(
              tooltip: 'Clear filter',
              onPressed: notifier.clearFilter,
              icon: const Icon(Icons.filter_alt_off),
            ),
        ],
      ),
    );
  }
}
