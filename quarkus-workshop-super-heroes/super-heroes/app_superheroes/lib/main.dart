import 'dart:async';
import 'dart:convert';

import 'package:app_superheroes/winner_score.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Super Heroes';
    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
        //channel: WebSocketChannel.connect(Uri.parse(
        webSocketUrl:
            'ws://192.168.42.12:8085/stats/winners', // wss://echo.websocket.org')),
      ),
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final String webSocketUrl;
  //final WebSocketChannel channel;

  MyHomePage({Key key, @required this.title, @required this.webSocketUrl})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller = TextEditingController();
  StreamController<String> _streamController = StreamController<String>();
  WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  _wserror(err) async {
    print(new DateTime.now().toString() + " Connection error: $err");
    await _connect();
  }

  _connect() async {
    if (_channel != null) {
      // add in a reconnect delay
      await Future.delayed(Duration(seconds: 4));
    }
    setState(() {
      print(new DateTime.now().toString() + " Starting connection attempt...");
      _channel = WebSocketChannel.connect(Uri.parse(widget.webSocketUrl));
      print(new DateTime.now().toString() + " Connection attempt completed.");
    });
    _channel.stream.listen((data) => _streamController.add(data),
        onDone: _connect, onError: _wserror, cancelOnError: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              child: TextFormField(
                controller: _controller,
                decoration:
                    InputDecoration(labelText: 'Schicke eine Nachricht!'),
              ),
            ),
            StreamBuilder(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List winnerScores = jsonDecode(snapshot.data);

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: winnerScores.length,
                    itemBuilder: (context, index) {
                      var winnerScore =
                          WinnerScore.fromJson(winnerScores[index]);

                      return ListTile(
                        leading: Icon(Icons.wine_bar),
                        title: Text(winnerScore.name),
                        trailing: Text(winnerScore.score.toString()),
                      );
                    },
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60.0),
                    child: Text('Waiting for winners...'),
                  );
                }
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Abschicken',
        child: Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty && _channel!=null) {
      _channel.sink.add(_controller.text);
    }
  }

  @override
  void dispose() {
    if (_channel!=null) {
      _channel.sink.close();
    }
    super.dispose();
  }
}
