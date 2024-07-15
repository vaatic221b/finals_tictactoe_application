import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get user => _auth.authStateChanges();

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

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

}
