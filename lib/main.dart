import 'package:flutter/material.dart' show AppBar, BuildContext, Card,Center, Colors, Column, CrossAxisAlignment, DropdownButtonFormField, DropdownMenuItem, EdgeInsets, Expanded, FilledButton, Icon, IconButton, InputDecoration, ListTile, ListView, MaterialApp, MaterialPageRoute, Navigator, Padding, Scaffold, SizedBox, State, StatefulWidget, StatelessWidget, Text, TextEditingController, TextField, TextFormField, TextInputType, Theme, ThemeData, Widget, Icons, Row, runApp;
import 'package:flutter/rendering.dart' show MainAxisAlignment, MainAxisSize;

void main() => runApp(const DixitScorekeeperApp());

// Créations de la classe Player pour stocker son nom et son score
class Player {
  Player(this.name);
  final String name;
  int score = 0;
}

// Classe Vote pour représenter le vote d'un joueur (voterIndex) pour une carte (cardIndex)
class Vote {
  Vote({required this.voterIndex, required this.cardIndex});
  final int voterIndex;
  final int cardIndex;
}

// Classe pour connecter les joueuers à leurs cartes jouées.
class CardPlayersConnection {
  CardPlayersConnection(this.cardIndex, this.cardOwnerIndex);
  final int cardIndex;
  final int cardOwnerIndex;
}

// Classe ExplicitVote pour représenter un vote explicite : qui a voté pour quelle carte, en reliant les indices de vote et de propriétaire de carte.
class ExplicitVote {
  ExplicitVote(this.voterIndex, this.cardOwnerIndex);
  final int voterIndex;
  final int cardOwnerIndex;
}

ExplicitVote makeExplicitVote({required Vote vote, required List<CardPlayersConnection> connections}) {
  final cardOwnerIndex = connections.firstWhere((c) => c.cardIndex == vote.cardIndex).cardOwnerIndex;
  return ExplicitVote(vote.voterIndex, cardOwnerIndex);
}

// Classe pour représenter le résultat d'un tour : les points gagnés par chaque joueur et un message explicatif.
class RoundResult {
  RoundResult(this.points, this.message);
  final List<int> points;
  final String message;
}

// Fonction pour calculer les points d'un tour de Dixit en fonction du nombre de joueurs, de l'index du conteur et des votes.
RoundResult computeDixitRound({
  required int playerCount,
  required int storytellerIndex,
  required List<ExplicitVote> votes,
}) {  final points = List<int>.filled(playerCount, 0);
  final eligibleVoters = List<int>.generate(playerCount, (i) => i)
      .where((i) => i != storytellerIndex)
      .toList();

  final correctVotes = votes
      .where((v) => v.cardOwnerIndex == storytellerIndex)
      .map((v) => v.voterIndex)
      .toSet();

  final allFound = correctVotes.length == eligibleVoters.length;
  final noneFound = correctVotes.isEmpty;

  if (allFound || noneFound) {
    for (final i in eligibleVoters) {
      points[i] += 2;
    }
  } else {
    // Variante officielle à 3 joueurs : si un seul joueur trouve l'image,
    // le conteur et ce joueur gagnent 4 points au lieu de 3.
    final base = playerCount == 3 && correctVotes.length == 1 ? 4 : 3;
    points[storytellerIndex] += base;
    for (final i in correctVotes) {
      points[i] += base;
    }
  }

  // Bonus : hors conteur, +1 par vote reçu sur son image.
  for (final v in votes) {
    if (v.cardOwnerIndex != storytellerIndex) {
      points[v.cardOwnerIndex] += 1;
    }
  }

  final message = allFound
      ? 'Tout le monde a trouvé : le conteur marque 0, les autres +2.'
      : noneFound
          ? 'Personne n’a trouvé : le conteur marque 0, les autres +2.'
          : 'Quelques joueurs ont trouvé : points du conteur et des bonnes réponses, puis bonus de votes.';
  return RoundResult(points, message);
}

class DixitScorekeeperApp extends StatelessWidget {
  const DixitScorekeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dixit Scorekeeper',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const SetupPage(),
    );
  }
}

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  static const int maxPlayers = 20;

  int playerCount = 4;
  late final TextEditingController playerCountController;
  final controllers = List.generate(
    maxPlayers,
    (i) => TextEditingController(text: 'Joueur ${i + 1}'),
  );

  @override
  void initState() {
    super.initState();
    playerCountController = TextEditingController(text: '$playerCount');
  }

  void setPlayerCount(int value) {
    final clamped = value.clamp(3, maxPlayers);
    setState(() {
      playerCount = clamped;
      playerCountController.text = '$playerCount';
    });
  }

  @override
  void dispose() {
    playerCountController.dispose();
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle partie Dixit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextFormField(
              controller: playerCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nombre de joueurs',
                suffixIcon: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_up),
                      onPressed: () => setPlayerCount(playerCount + 1),
                      tooltip: 'Augmenter',
                    ),
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onPressed: () => setPlayerCount(playerCount - 1),
                      tooltip: 'Diminuer',
                    ),
                  ],
                ),
              ),
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null) {
                  setPlayerCount(parsed);
                }
              },
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < playerCount; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: controllers[i],
                  decoration: InputDecoration(labelText: 'Nom joueur ${i + 1}'),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final players = List.generate(
                  playerCount,
                  (i) => Player(controllers[i].text.trim().isEmpty ? 'Joueur ${i + 1}' : controllers[i].text.trim()),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => GamePage(players: players)),
                );
              },
              child: const Text('Commencer'),
            ),
          ],
        ),
      ),
    );
  }
}


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
            Text('Conteur : ${players[storytellerIndex].name}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  for (var i = 0; i < players.length; i++)
                    Card(
                      child: ListTile(
                        title: Text(players[i].name),
                        trailing: Text('${players[i].score} pts', style: Theme.of(context).textTheme.titleMedium),
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
                    builder: (_) => VotePage(players: players, storytellerIndex: storytellerIndex),
                  ),
                );
                if (votes == null) return;
                if (!mounted) return;

                final explicitVotes = await Navigator.push<List<ExplicitVote>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExplicitVotePage(players: players, votes: votes, storytellerIndex: storytellerIndex),
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

class VotePage extends StatefulWidget {
  const VotePage({super.key, required this.players, required this.storytellerIndex});
  final List<Player> players;
  final int storytellerIndex;

  @override
  State<VotePage> createState() => _VotePageState();
}

class ExplicitVotePage extends StatefulWidget {
  const ExplicitVotePage({super.key, required this.players, required this.votes, required this.storytellerIndex});
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
      // advance to next unassigned card
      currentCard = ownerByCard.length < widget.players.length
          ? (ownerByCard.keys.toList()..sort()).last + 1
          : widget.players.length;
      if (currentCard >= widget.players.length) currentCard = widget.players.length;
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
    final availablePlayers = List<int>.generate(total, (i) => i).where((i) => !ownerByCard.values.contains(i)).toList();

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
              Text('Carte ${currentCard + 1} / $total', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: Text('Carte ${currentCard + 1}'),
                  subtitle: Text(currentCard == widget.storytellerIndex ? 'Carte du conteur' : ''),
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
                        child: ListTile(
                          title: Text(players[p].name),
                          subtitle: p == widget.storytellerIndex ? const Text('— carte du conteur') : null,
                          onTap: () => assignOwner(currentCard, p),
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
                          title: Text('Carte ${card + 1} → ${players[ownerByCard[card]!].name}'),
                          subtitle: ownerByCard[card] == widget.storytellerIndex ? const Text('— carte du conteur') : null,
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
            const Text('Qui a voté pour quelle image ?\nOn ne peut pas voter pour sa propre image.'),
            const SizedBox(height: 12),
            for (final voter in voters)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<int>(
                  initialValue: selectedOwnerByVoter[voter],
                  decoration: InputDecoration(labelText: 'Vote de ${players[voter].name}'),
                  items: [
                    for (var owner = 0; owner < players.length; owner++)
                      if (owner != voter)
                            DropdownMenuItem(
                              value: owner,
                              child: Text('Carte ${owner + 1}'),
                            ),
                  ],
                  onChanged: (v) => setState(() => selectedOwnerByVoter[voter] = v),
                ),
              ),
            FilledButton(
              onPressed: selectedOwnerByVoter.values.any((v) => v == null)
                  ? null
                  : () {
                      Navigator.pop(
                        context,
                        selectedOwnerByVoter.entries
                            .map((e) => Vote(voterIndex: e.key, cardIndex: e.value!))
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
