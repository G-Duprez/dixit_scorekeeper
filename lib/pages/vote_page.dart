import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/vote.dart';

class VotePage extends StatefulWidget {
  const VotePage({
    super.key,
    required this.players,
    required this.storytellerIndex,
  });

  final List<Player> players;
  final int storytellerIndex;

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  late final Map<int, int?> selectedOwnerByVoter;

  @override
  void initState() {
    super.initState();
    selectedOwnerByVoter = {
      for (var i = 0; i < widget.players.length; i++)
        if (i != widget.storytellerIndex) i: null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final players = widget.players;
    final voters = selectedOwnerByVoter.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Votes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Qui a voté pour quelle image ?'),
            const SizedBox(height: 12),
            for (final voter in voters)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<int>(
                  initialValue: selectedOwnerByVoter[voter],
                  decoration: InputDecoration(
                    labelText: 'Vote de ${players[voter].name}',
                  ),
                  items: [
                    for (var card = 0; card < players.length; card++)
                      DropdownMenuItem(
                        value: card,
                        child: Text('Carte ${card + 1}'),
                      ),
                  ],
                  onChanged: (v) =>
                      setState(() => selectedOwnerByVoter[voter] = v),
                ),
              ),
            FilledButton(
              onPressed: selectedOwnerByVoter.values.any((v) => v == null)
                  ? null
                  : () {
                      Navigator.pop(
                        context,
                        selectedOwnerByVoter.entries
                            .map(
                              (e) => Vote(
                                voterIndex: e.key,
                                cardIndex: e.value!,
                              ),
                            )
                            .toList(),
                      );
                    },
              child: const Text('Valider le tour'),
            ),
          ],
        ),
      ),
    );
  }
}
