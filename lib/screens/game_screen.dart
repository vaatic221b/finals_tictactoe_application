import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finals_tictactoe_application/services/auth_service.dart';
import 'package:finals_tictactoe_application/services/game_service.dart';

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
  GameService? gameService;

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
    gameService = Provider.of<GameService>(context, listen: false);
  }

  @override
  void dispose() {
    gameService?.leaveGame(widget.gameId);
    super.dispose();
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
                      gameService?.makeMove(widget.gameId, index);
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
                  onPressed: () {
                    gameService?.initiateRematch(widget.gameId);
                  },
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
