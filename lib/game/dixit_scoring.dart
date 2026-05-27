import '../models/round_result.dart';
import '../models/vote.dart';

RoundResult computeDixitRound({
  required int playerCount,
  required int storytellerIndex,
  required List<ExplicitVote> votes,
}) {
  final points = List<int>.filled(playerCount, 0);
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
    // Official 3-player variant: if only one player finds the image,
    // the storyteller and that player get 4 points instead of 3.
    final base = playerCount == 3 && correctVotes.length == 1 ? 4 : 3;
    points[storytellerIndex] += base;
    for (final i in correctVotes) {
      points[i] += base;
    }
  }

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
