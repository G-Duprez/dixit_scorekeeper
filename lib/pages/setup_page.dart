import 'package:flutter/material.dart';

import '../models/player.dart';
import 'game_page.dart';

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
                  (i) => Player(
                    controllers[i].text.trim().isEmpty
                        ? 'Joueur ${i + 1}'
                        : controllers[i].text.trim(),
                  ),
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
