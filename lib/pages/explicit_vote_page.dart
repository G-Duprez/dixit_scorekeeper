import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/vote.dart';

class ExplicitVotePage extends StatefulWidget {
  const ExplicitVotePage({
    super.key,
    required this.players,
    required this.votes,
    required this.storytellerIndex,
  });

  final List<Player> players;
  final List<Vote> votes;
  final int storytellerIndex;

  @override
  State<ExplicitVotePage> createState() => _ExplicitVotePageState();
}

class _ExplicitVotePageState extends State<ExplicitVotePage> {
  final Map<int, int> ownerByCard = {};
  int currentCard = 0;

  void assignOwner(int cardIndex, int playerIndex) {
    setState(() {
      ownerByCard[cardIndex] = playerIndex;
      currentCard = ownerByCard.length < widget.players.length
          ? (ownerByCard.keys.toList()..sort()).last + 1
          : widget.players.length;
      if (currentCard >= widget.players.length) {
        currentCard = widget.players.length;
      }
    });
  }

  void goPrevious() {
    if (ownerByCard.isEmpty) return;
    final lastCard = (ownerByCard.keys.toList()..sort()).last;
    setState(() {
      ownerByCard.remove(lastCard);
      currentCard = lastCard;
    });
  }

  List<ExplicitVote> computeExplicitVotes() {
    return widget.votes
        .map((v) => ExplicitVote(v.voterIndex, ownerByCard[v.cardIndex]!))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final players = widget.players;
    final total = players.length;
    final assignedCount = ownerByCard.length;
    final isComplete = assignedCount == total;
    final availablePlayers = List<int>.generate(total, (i) => i)
        .where((i) => !ownerByCard.values.contains(i))
        .toList();
    final voteByPlayer = {
      for (final vote in widget.votes) vote.voterIndex: vote.cardIndex
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Révélation des propriétaires')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Attribuez un joueur à chaque carte (1..$total).'),
            const SizedBox(height: 12),
            if (!isComplete) ...[
              Text(
                'Carte ${currentCard + 1} / $total',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: Text('Carte ${currentCard + 1}'),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Sélectionnez le joueur qui a joué cette carte :'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    for (final p in availablePlayers)
                      Card(
                        color: voteByPlayer[p] == currentCard
                            ? Colors.red.shade100
                            : null,
                        child: ListTile(
                          title: Text(players[p].name),
                          subtitle: voteByPlayer[p] == currentCard
                              ? Text(
                                  'A voté pour la carte ${voteByPlayer[p]! + 1} - Vous ne pouvez pas voter pour votre propre carte',
                                )
                              : p == widget.storytellerIndex
                                  ? const Text('Carte du conteur')
                                  : voteByPlayer[p] != null
                                      ? Text(
                                          'A voté pour la carte ${voteByPlayer[p]! + 1}',
                                        )
                                      : null,
                          onTap: voteByPlayer[p] == currentCard
                              ? null
                              : () => assignOwner(currentCard, p),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: ownerByCard.isEmpty ? null : goPrevious,
                      child: const Text('Précédent'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Text('Attributions terminées — récapitulatif :'),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    for (var card = 0; card < total; card++)
                      Card(
                        child: ListTile(
                          title: Text(
                            'Carte ${card + 1} → ${players[ownerByCard[card]!].name}',
                          ),
                          subtitle: ownerByCard[card] == widget.storytellerIndex
                              ? const Text('— carte du conteur')
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () {
                  final explicit = computeExplicitVotes();
                  Navigator.pop(context, explicit);
                },
                child: const Text('Confirmer et appliquer le tour'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
