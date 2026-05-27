import 'package:flutter/material.dart';

import '../game/dixit_scoring.dart';
import '../models/player.dart';
import '../models/vote.dart';
import 'explicit_vote_page.dart';
import 'vote_page.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.players});

  final List<Player> players;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int storytellerIndex = 0;
  int roundNumber = 1;
  String lastRoundMessage = '';

  void applyRound(List<ExplicitVote> votes) {
    final result = computeDixitRound(
      playerCount: widget.players.length,
      storytellerIndex: storytellerIndex,
      votes: votes,
    );
    setState(() {
      for (var i = 0; i < widget.players.length; i++) {
        widget.players[i].score += result.points[i];
      }
      lastRoundMessage = 'Tour $roundNumber : ${result.message}\n'
          '${List.generate(widget.players.length, (i) => '${widget.players[i].name} +${result.points[i]}').join(' · ')}';
      storytellerIndex = (storytellerIndex + 1) % widget.players.length;
      roundNumber += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final players = widget.players;
    return Scaffold(
      appBar: AppBar(title: Text('Dixit — Tour $roundNumber')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Conteur : ${players[storytellerIndex].name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  for (var i = 0; i < players.length; i++)
                    Card(
                      child: ListTile(
                        title: Text(players[i].name),
                        trailing: Text(
                          '${players[i].score} pts',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  if (lastRoundMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(lastRoundMessage),
                    ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () async {
                final votes = await Navigator.push<List<Vote>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VotePage(
                      players: players,
                      storytellerIndex: storytellerIndex,
                    ),
                  ),
                );
                if (votes == null) return;
                if (!context.mounted) return;

                final explicitVotes = await Navigator.push<List<ExplicitVote>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExplicitVotePage(
                      players: players,
                      votes: votes,
                      storytellerIndex: storytellerIndex,
                    ),
                  ),
                );
                if (!mounted) return;
                if (explicitVotes != null) applyRound(explicitVotes);
              },
              child: const Text('Saisir les votes du tour'),
            ),
          ],
        ),
      ),
    );
  }
}
