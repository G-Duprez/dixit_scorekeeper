class Vote {
  Vote({required this.voterIndex, required this.cardIndex});

  final int voterIndex;
  final int cardIndex;
}

class CardPlayersConnection {
  CardPlayersConnection(this.cardIndex, this.cardOwnerIndex);

  final int cardIndex;
  final int cardOwnerIndex;
}

class ExplicitVote {
  ExplicitVote(this.voterIndex, this.cardOwnerIndex);

  final int voterIndex;
  final int cardOwnerIndex;
}

ExplicitVote makeExplicitVote({
  required Vote vote,
  required List<CardPlayersConnection> connections,
}) {
  final cardOwnerIndex = connections
      .firstWhere((c) => c.cardIndex == vote.cardIndex)
      .cardOwnerIndex;
  return ExplicitVote(vote.voterIndex, cardOwnerIndex);
}
