import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GameService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> leaveGame(String gameId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    DocumentReference gameRef = _firestore.collection('games').doc(gameId);
    DocumentSnapshot gameSnapshot = await gameRef.get();
    Map<String, dynamic> gameData = gameSnapshot.data() as Map<String, dynamic>;

    if (gameData['player1'] == currentUser.uid) {
      await gameRef.update({'player1': null});
    } else if (gameData['player2'] == currentUser.uid) {
      await gameRef.update({'player2': null});
    }

    await resetGame(gameId);
  }

  Future<void> resetGame(String gameId) async {
    DocumentReference gameRef = _firestore.collection('games').doc(gameId);
    DocumentSnapshot gameSnapshot = await gameRef.get();
    Map<String, dynamic> gameData = gameSnapshot.data() as Map<String, dynamic>;

    String? newCurrentTurn;
    if (gameData['player1'] != null) {
      newCurrentTurn = gameData['player1'];
    } else if (gameData['player2'] != null) {
      newCurrentTurn = gameData['player2'];
    } else {
      newCurrentTurn = null;
    }

    await gameRef.update({
      'board': List.generate(9, (_) => ''),
      'currentTurn': newCurrentTurn,
      'winner': null,
    });
  }

  Future<void> makeMove(String gameId, int index) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    DocumentReference gameRef = _firestore.collection('games').doc(gameId);
    DocumentSnapshot gameSnapshot = await gameRef.get();
    Map<String, dynamic> gameData = gameSnapshot.data() as Map<String, dynamic>;

    if (gameData['board'][index] != '' || gameData['winner'] != null) return;

    if (gameData['currentTurn'] != currentUser.uid) return;

    gameData['board'][index] = currentUser.uid;
    gameData['currentTurn'] = (gameData['currentTurn'] == gameData['player1'])
        ? gameData['player2']
        : gameData['player1'];

    await gameRef.update({
      'board': gameData['board'],
      'currentTurn': gameData['currentTurn'],
    });

    checkWinner(gameId);
  }

  void checkWinner(String gameId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    DocumentReference gameRef = _firestore.collection('games').doc(gameId);
    DocumentSnapshot gameSnapshot = await gameRef.get();
    Map<String, dynamic> gameData = gameSnapshot.data() as Map<String, dynamic>;

    List<String> board = List<String>.from(gameData['board']);
    List<List<int>> winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (List<int> combination in winningCombinations) {
      String a = board[combination[0]];
      String b = board[combination[1]];
      String c = board[combination[2]];
      if (a == b && b == c && a != '') {
        await gameRef.update({
          'winner': a,
        });
        return;
      }
    }

    if (!board.contains('')) {
      await gameRef.update({
        'winner': 'Draw',
      });
    }
  }

  Future<void> initiateRematch(String gameId) async {
    await resetGame(gameId);
  }
}
