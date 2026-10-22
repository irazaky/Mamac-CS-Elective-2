import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/nickname_provider.dart';
import '../utils/text_utils.dart';

/// Opens the nickname editor for one Pokémon.
Future<void> showNicknameDialog(BuildContext context, Pokemon pokemon) {
  return showDialog<void>(
    context: context,
    builder: (_) => NicknameDialog(pokemon: pokemon),
  );
}

/// Text input + Save / Remove / Cancel for a Pokémon's nickname.
class NicknameDialog extends ConsumerStatefulWidget {
  final Pokemon pokemon;

  const NicknameDialog({super.key, required this.pokemon});

  @override
  ConsumerState<NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends ConsumerState<NicknameDialog> {
  late final TextEditingController _controller;
  late final bool _hasNickname;

  @override
  void initState() {
    super.initState();
    final current = ref.read(nicknameProvider)[widget.pokemon.id];
    _hasNickname = current != null;
    _controller = TextEditingController(text: current ?? '');
  }

  @override
  void dispose() {
    _controller.dispose(); // free the controller when the dialog closes
    super.dispose();
  }

  void _save() {
    ref
        .read(nicknameProvider.notifier)
        .setNickname(widget.pokemon.id, _controller.text);
    Navigator.of(context).pop();
  }

  void _remove() {
    ref.read(nicknameProvider.notifier).removeNickname(widget.pokemon.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_hasNickname ? 'Edit nickname' : 'Add nickname'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Original name: ${capitalize(widget.pokemon.name)}'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 20,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nickname',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
      actions: [
        if (_hasNickname)
          TextButton(
            onPressed: _remove,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
