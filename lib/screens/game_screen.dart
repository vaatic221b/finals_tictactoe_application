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
  TextEditingController _chatController = TextEditingController();
  String? player1Id;
  String? player2Id;

  @override
  void initState() {
    super.initState();
    gameRef = FirebaseFirestore.instance.collection('games').doc(widget.gameId);
    gameStream = gameRef.snapshots();
    _initializePlayers();
  }

  void _initializePlayers() async {
    DocumentSnapshot gameSnapshot = await gameRef.get();
    Map<String, dynamic> gameData = gameSnapshot.data() as Map<String, dynamic>;
    setState(() {
      player1Id = gameData['player1'];
      player2Id = gameData['player2'];
    });
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
    _chatController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final currentUser = authService?.currentUser;
    if (currentUser != null && _chatController.text.trim().isNotEmpty) {
      await gameService?.sendMessage(widget.gameId, currentUser.uid, _chatController.text.trim());
      _chatController.clear();
    }
  }

  String _getPlayerLabel(String userId) {
    if (userId == player1Id) return 'Player 1';
    if (userId == player2Id) return 'Player 2';
    return 'Player 2'; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWithChat(),
      endDrawer: chatBoxDrawer(),
      body: Stack(
        children: [
          backgroundImage(),
          Center(
            child: StreamBuilder<DocumentSnapshot>(
              stream: gameStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                Map<String, dynamic> gameData = snapshot.data!.data() as Map<String, dynamic>;
                List<String> board = List<String>.from(gameData['board']);
                String? currentTurn = gameData['currentTurn'];
                String? winner = gameData['winner'];
                int player1Wins = gameData['player1Wins'];
                int player2Wins = gameData['player2Wins'];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    gameIDtopText(),
                    const SizedBox(height: 10),
                    winCounter(player1Wins, player2Wins),
                    const SizedBox(height: 10),
                    gameGrid(board, gameData),
                    SizedBox(height: 20),
                    if (currentTurn != null && winner == null)
                      currentTurnDisplay(currentTurn, gameData),
                    if (winner != null) ...[
                      winnerDisplay(winner, gameData),
                      const SizedBox(height: 20),
                      rematchButton(),
                    ],
                    if (gameData['player1'] == null || gameData['player2'] == null)
                      awaitPlayerText(),
                      const Spacer()
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Text awaitPlayerText() {
    return const Text('Waiting for a player to join...',
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 3.0),
                              blurRadius: 1.0,
                              color: Colors.black,
                            ),
                          ]
                        )
                    );
  }

  ElevatedButton rematchButton() {
    return ElevatedButton(
                      onPressed: () {
                        gameService?.initiateRematch(widget.gameId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Text(
                        'Rematch',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
  }

  Text winnerDisplay(String winner, Map<String, dynamic> gameData) {
    if (winner == 'Draw') {
      return Text(
        'Draw',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white, 
        ),
      );
    } else {
      return Text(
        'Winner: ${winner == gameData['player1'] ? 'Player 1' : 'Player 2'}',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: winner == gameData['player1']
              ? Color(0xFFE94A5A)
              : Color(0xFF4AB6D8), 
        ),
      );
    }
  }


  Text currentTurnDisplay(String currentTurn, Map<String, dynamic> gameData) {
    return Text('Turn: ${currentTurn == gameData['player1'] ? 'Player 1' : 'Player 2'}',
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 3.0),
                              blurRadius: 1.0,
                              color: Colors.black,
                            ),
                          ]
                        ));
  }

  GridView gameGrid(List<String> board, Map<String, dynamic> gameData) {
    return GridView.builder(
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
                            decoration: BoxDecoration(
                              color: Color(0xFFDCF4FF),
                              border: Border.all(color: Color(0xFF6A6271), width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                board[index] == gameData['player1']
                                    ? 'X'
                                    : board[index] == gameData['player2']
                                        ? 'O'
                                        : '',
                                style: TextStyle(
                                  fontSize: 70,
                                  color: board[index] == gameData['player1']
                                      ? Color(0xFFE94A5A) 
                                      : board[index] == gameData['player2']
                                          ? Color(0xFF4AB6D8) 
                                          : Colors.white, 
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
  }

  Container winCounter(int player1Wins, int player2Wins) {
    return Container(
                  width: 350,
                  height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(1.0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blueAccent, width: 2),
                    ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Player 1 Wins: $player1Wins',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          )),
                      Text('Player 2 Wins: $player2Wins',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          )),
                    ],
                  ),
                );
  }

  Container gameIDtopText() {
    return Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(1.0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blueAccent, width: 2),
                    ),
                    child: Text(
                      'Game ID: ${widget.gameId}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  );
  }

  Container backgroundImage() {
    return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        );
  }

  Drawer chatBoxDrawer() {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: gameService?.getMessages(widget.gameId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index].data() as Map<String, dynamic>;
                    var message = messageData['message'];
                    var userId = messageData['userId'];

                    return ListTile(
                      title: Text(_getPlayerLabel(userId), style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(message),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar appbarWithChat() {
    return AppBar(
      title: Text('Tic-Tac-Toe Game', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
      backgroundColor: Colors.blueAccent,
      actions: [
        Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.chat),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            );
          },
        ),
      ],
    );
  }

}
