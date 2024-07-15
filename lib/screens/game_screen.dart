import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finals_tictactoe_application/services/auth_service.dart';

class GameScreen extends StatefulWidget {
  final String gameId;

  GameScreen({required this.gameId});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late DocumentReference gameRef;
  late Stream<DocumentSnapshot> gameStream;
  AuthService? authService;

  @override
  void initState() {
    super.initState();
    gameRef = FirebaseFirestore.instance.collection('games').doc(widget.gameId);
    gameStream = gameRef.snapshots();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authService = Provider.of<AuthService>(context, listen: false);
  }

  @override
  void dispose() {
    leaveGame();
    super.dispose();
  }

  Future<void> leaveGame() async {
    final currentUser = authService?.currentUser;
    if (currentUser == null) return;

    DocumentSnapshot gameSnapshot = await gameRef.get();
    Map<String, dynamic> gameData = gameSnapshot.data() as Map<String, dynamic>;

    if (gameData['player1'] == currentUser.uid) {
      await gameRef.update({'player1': null});
    } else if (gameData['player2'] == currentUser.uid) {
      await gameRef.update({'player2': null});
    }

    await resetGame();
  }

  Future<void> resetGame() async {
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

  Future<void> makeMove(int index) async {
    final currentUser = authService?.currentUser;
    if (currentUser == null) return;

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

    checkWinner(gameData);
  }

  void checkWinner(Map<String, dynamic> gameData) async {
    final currentUser = authService?.currentUser;
    if (currentUser == null) return;

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

  void initiateRematch() async {
    await resetGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic-Tac-Toe Game'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: gameStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic> gameData = snapshot.data!.data() as Map<String, dynamic>;
          List<String> board = List<String>.from(gameData['board']);
          String? currentTurn = gameData['currentTurn'];
          String? winner = gameData['winner'];

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      makeMove(index);
                    },
                    child: GridTile(
                      child: Container(
                        margin: EdgeInsets.all(4.0),
                        color: Colors.blue,
                        child: Center(
                          child: Text(
                            board[index] == gameData['player1']
                                ? 'X'
                                : board[index] == gameData['player2']
                                    ? 'O'
                                    : '',
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              if (currentTurn != null)
                Text('Turn: ${currentTurn == gameData['player1'] ? 'Player 1' : 'Player 2'}'),
              if (winner != null) ...[
                Text('Winner: ${winner == 'Draw' ? 'Draw' : winner == gameData['player1'] ? 'Player 1' : 'Player 2'}'),
                ElevatedButton(
                  onPressed: initiateRematch,
                  child: Text('Rematch'),
                ),
              ],
              if (gameData['player1'] == null || gameData['player2'] == null) 
                Text('Waiting for a player to join...'),
            ],
          );
        },
      ),
    );
  }
}
