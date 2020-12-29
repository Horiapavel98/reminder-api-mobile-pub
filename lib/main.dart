import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:animated_text_kit/animated_text_kit.dart';

// Import second screen transition
import 'package:reminder_client_mobile/second_screen.dart';
import 'package:reminder_client_mobile/router.dart';

void main() {
  runApp(TunnelScreen());
}

class TunnelScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TunnelSelectPage(title: 'Flutter Login'),
    );
  }
}

class TunnelSelectPage extends StatefulWidget {
  TunnelSelectPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TunnelPageState createState() => _TunnelPageState();
}

class _TunnelPageState extends State<TunnelSelectPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  TextField tunnelField = TextField();

  String tunnelId;

  TextEditingController textFieldController = TextEditingController();

  _validateTunnelId(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (textFieldController.text.isEmpty) {
      showAlertDialog(context, "Field empty", "Tunnel field is empty; required to fill 🔄");
      return;
    }

    String url = "https://" + textFieldController.text + ".ngrok.io";
    final response = await http.get(url);

    if (response.statusCode == 200) {
      Navigator.of(context).push(createRoute(ReminderScreen(tunnelId: tunnelId)));
    } else {
      showAlertDialog(context, "Connection error", "Could not contact Reminder API service ❌⌚");
    }
  }

  @override
  Widget build(BuildContext context) {
    tunnelField = TextField(
      autofocus: false,
      obscureText: false,
      style: style,
      controller: textFieldController,
      onChanged: (text) {
        tunnelId = text;
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Tunnel ID",
        border:
        OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );
    final connectButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Color(0xff01A0C7),
        child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: () {
              _validateTunnelId(context);
            },
            child: Text("Connect",
              textAlign: TextAlign.center,
              style: style.copyWith(
                  color: Colors.white, fontWeight: FontWeight.bold
              ),
            )
        )
    );

    final exitButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Color(0xffffffff),
        child: MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(color: Color(0xff01A0C7), width: 3),
            ),
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: () {SystemNavigator.pop();},
            child: Text("Exit",
              textAlign: TextAlign.center,
              style: style.copyWith(
                  color: Color(0xff01A0C7), fontWeight: FontWeight.bold
              ),
            )
        )
    );

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(36.0, 150, 36.0, 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget> [
                Row(
                  children: [
                    SizedBox(
                      child: Text("Re", style: TextStyle(
                        fontFamily: "Pacifico",
                        fontSize: 50.0,
                        color: Colors.greenAccent,
                      ),
                      ),
                    ),
                    SizedBox(
                      width: 250.0,
                      child: TypewriterAnimatedTextKit(
                        isRepeatingAnimation: false,
                        // pause: const Duration(milliseconds: 500),
                        text: [
                          "minder",
                          "member",
                          "organise",
                        ],
                        textStyle: TextStyle(
                          fontFamily: "Pacifico",
                          fontSize: 50.0,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
                /*SizedBox(
                  height: 155.0,
                  child: Image.asset(
                    "assets/Inside_text.png",
                    fit: BoxFit.contain,
                  ),
                ),*/
                SizedBox(height: 45.0),
                tunnelField,
                SizedBox(height: 35.0),
                connectButton,
                SizedBox(height: 15.0),
                exitButton,
                SizedBox(height: 15.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}