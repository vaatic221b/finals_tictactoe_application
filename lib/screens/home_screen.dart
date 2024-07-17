import 'package:finals_tictactoe_application/screens/login_screen.dart';
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
        title: Text('Tic-Tac-Toe Home', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
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
                          title: Text('Game Created', style: TextStyle(color: Colors.blueAccent)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Game ID: $gameId', style: TextStyle(fontSize: 18)),
                              SizedBox(height: 20),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GameScreen(gameId: gameId),
                                    ),
                                  );
                                },
                                child: Text("Let's go!", style: TextStyle(color: Colors.blueAccent)),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Close', style: TextStyle(color: Colors.blueAccent)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text('Host Game'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    TextEditingController gameIdController = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Join Game', style: TextStyle(color: Colors.blueAccent)),
                          content: TextField(
                            controller: gameIdController,
                            decoration: InputDecoration(
                              labelText: 'Enter Game ID',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
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
                              child: Text('Join', style: TextStyle(color: Colors.blueAccent)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text('Join Game', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
