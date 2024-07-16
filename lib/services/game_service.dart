import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GameService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  String generateGameId() {
    const length = 6;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<String> createGame() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('No user logged in');

    String gameId = generateGameId();
    await _firestore.collection('games').doc(gameId).set({
      'player1': currentUser.uid,
      'player2': null,
      'currentTurn': currentUser.uid,
      'board': List<String>.filled(9, ''),
      'winner': null,
    });

    return gameId;
  }

  Future<void> joinGame(String gameId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('No user logged in');

    DocumentReference gameRef = _firestore.collection('games').doc(gameId);
    DocumentSnapshot gameSnapshot = await gameRef.get();
    Map<String, dynamic> gameData = gameSnapshot.data() as Map<String, dynamic>;

    // Check if the player is already in the game
    if (gameData['player1'] == currentUser.uid || gameData['player2'] == currentUser.uid) {
      // Player is already in the game
      return;
    }

    // Check if player1 slot is available
    if (gameData['player1'] == null) {
      await gameRef.update({'player1': currentUser.uid});
    } else if (gameData['player2'] == null) {
      await gameRef.update({'player2': currentUser.uid});
    } else {
      throw Exception('Game is already full');
    }
  }

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

    // Check if both players have left and delete the game if true
    final updatedGameDoc = await gameRef.get();
    final updatedGameData = updatedGameDoc.data() as Map<String, dynamic>;
    if (updatedGameData['player1'] == null && updatedGameData['player2'] == null) {
      await gameRef.delete();
    } else {
      await resetGame(gameId);
    }
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

  Future<void> sendMessage(String gameId, String userId, String message) async {
    await _firestore.collection('games').doc(gameId).collection('messages').add({
      'userId': userId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMessages(String gameId) {
    return _firestore.collection('games').doc(gameId).collection('messages').orderBy('timestamp').snapshots();
  }
}
