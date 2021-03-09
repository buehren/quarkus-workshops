import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_auth_ui/flutter_auth_ui.dart';

import 'package:app_superheroes/winner_score.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final title = 'Super Heroes';
    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
        //channel: WebSocketChannel.connect(Uri.parse('wss://echo.websocket.org')),
        webSocketUrl:
            //'ws://echo.websocket.org/',
            //'wss://whiteboard-vsv4xsncya-ey.a.run.app/socket.io/?EIO=4&transport=websocket&sid=o96rAY715GjGB9E0AAAC&flutter',
            //'ws://localhost:8085/stats/winners',
            //'ws://192.168.42.12:8085/stats/winners',
            'wss://event-statistics-vsv4xsncya-ey.a.run.app/stats/winners',
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

  MyHomePage({Key? key, required this.title, required this.webSocketUrl})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller = TextEditingController();
  StreamController<String> _streamController = StreamController<String>();
  WebSocketChannel? _channel;
  //WebSocket _webSocket;
  bool _hasStartedConnect = false;
  bool _isSocketOpen = false;
  User? _user = null;

  @override
  void initState() {
    super.initState();
    _isSocketOpen = false;
    _user = null;

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
      if (user == null) {
        print('User is signed out!');
      } else {
        print('User is signed in! ' + user.toString());
      }
    });

    _connect();
  }

  _wserror(err) async {
    setState(() {
      _isSocketOpen = false;
    });

    print(new DateTime.now().toString() + " Connection error: $err");
    await _connect();
  }

  _connect() async {
    setState(() {
      _isSocketOpen = false;
    });

    if (_channel != null) {
      print("connect");
    }
    //if (_webSocket!=null) {
    //  print("connect: WebSocket readyState: " + (_webSocket.readyState.toString()));
    //}

    if (_hasStartedConnect) {
      // add in a reconnect delay
      await Future.delayed(Duration(seconds: 4));
    }

    //Future<WebSocket> futureWebSocket;
    setState(() {
      print(new DateTime.now().toString() +
          " Starting connection attempt to " +
          widget.webSocketUrl +
          " ...");

      _channel = WebSocketChannel.connect(Uri.parse(widget.webSocketUrl));

      /* Does not (yet) work in Web mode: "Error: Unsupported operation: Platform._version"
      //futureWebSocket = WebSocket.connect(widget.webSocketUrl);

      WebSocket.connect(widget.webSocketUrl).then((ws) {
        _channel = IOWebSocketChannel(ws);

        print(new DateTime.now().toString() + " Connection established.");
      });
      */

      _hasStartedConnect = true;
    });

    _channel?.stream.listen((data) {
      print("Received data: $data");
      setState(() {
        _isSocketOpen = true;
      });
      _streamController.add(data);
    }, onDone: _connect, onError: _wserror, cancelOnError: true);

/*
    futureWebSocket.then((WebSocket ws) {
      _webSocket = ws;
      print("WebSocket readyState: " + (_webSocket.readyState.toString()));

      //print("Sending text to WebSocket before listen");
      //_webSocket.add("Sending text to WebSocket before listen");

      _webSocket.listen((data) {
        print("Received data: $data");
        setState(() {
          _isSocketOpen = true;
        });
        _streamController.add(data);
      }, onError: _wserror, onDone: _connect);

      //print("Sending text to WebSocket after listen");
      //_webSocket.add("Sending text to WebSocket after listen");

      // send message
      //print("Sending hello");
      //_webSocket.add('hello websocket world');
    });
*/
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
            Visibility(
              child: ElevatedButton(
                child: const Text("Login"),
                onPressed: () async {
                  startAuthUi();
                },
              ),
              visible: _user == null,
            ),
            Visibility(
              child: ElevatedButton(
                  child: const Text("Logout"),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  }),
              visible: _user != null,
            ),
            Form(
              child: TextFormField(
                enabled: _isSocketOpen,
                controller: _controller,
                decoration:
                    InputDecoration(labelText: 'Schicke eine Nachricht!'),
              ),
            ),
            StreamBuilder(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List winnerScores = jsonDecode(snapshot.data.toString());

                  return Expanded(
                      child: ListView.builder(
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
                    ));
                } else {
                  return Expanded(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60.0),
                    child: Text('Waiting for winners...'),
                  ));
                }
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isSocketOpen ? _sendMessage : null,
        tooltip: 'Abschicken',
        child: Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      print("Sending message: " + _controller.text);
      _channel?.sink.add(_controller.text);
      //_webSocket.add(_controller.text);
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    //_webSocket.close();
    super.dispose();
  }

  void startAuthUi() {
    final providers = [
      //AuthUiItem.AuthAnonymous,
      AuthUiItem.AuthEmail,
      //AuthUiItem.AuthPhone,
      //AuthUiItem.AuthApple,
      //AuthUiItem.AuthGithub,
      //AuthUiItem.AuthGoogle,
      //AuthUiItem.AuthMicrosoft,
      //AuthUiItem.AuthYahoo,
    ];

    final result = /*await*/ FlutterAuthUi.startUi(
      items: providers,
      tosAndPrivacyPolicy: TosAndPrivacyPolicy(
        tosUrl: "https://www.example.com/termsofservice",
        privacyPolicyUrl: "https://www.example.com/privacypolicy",
      ),
      //androidOption: AndroidOption(
      //  enableSmartLock: false, // default true
      //),
      emailAuthOption: EmailAuthOption(
        requireDisplayName: false,
        // default true
        enableMailLink: false,
        // default false
        handleURL: '',
        androidPackageName: '',
        androidMinimumVersion: '',
      ),
    );
    print("Auth result: " + result.toString());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<WebSocketChannel>('_channel', _channel));
    //properties.add(DiagnosticsProperty<WebSocket>('_webSocket', _webSocket));
  }
}
