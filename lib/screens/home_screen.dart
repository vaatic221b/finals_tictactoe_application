import 'package:finals_tictactoe_application/services/game_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finals_tictactoe_application/services/auth_service.dart';
import 'package:finals_tictactoe_application/screens/game_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                String gameId = await Provider.of<GameService>(context, listen: false).createGame();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Game Created'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Game ID: $gameId'),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GameScreen(gameId: gameId),
                                ),
                              );
                            },
                            child: Text('Start Game'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Start New Game'),
            ),
            ElevatedButton(
              onPressed: () async {
                TextEditingController gameIdController = TextEditingController();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Join Game'),
                      content: TextField(
                        controller: gameIdController,
                        decoration: InputDecoration(labelText: 'Enter Game ID'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            try {
                              await Provider.of<GameService>(context, listen: false)
                                  .joinGame(gameIdController.text.trim());
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GameScreen(gameId: gameIdController.text.trim()),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to join game: $e')),
                              );
                            }
                          },
                          child: Text('Join'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Join Game'),
            ),
          ],
        ),
      ),
    );
  }
}
