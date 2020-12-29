import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:reminder_client_mobile/router.dart';

class ReminderScreen extends StatelessWidget {

  final String tunnelId;

  ReminderScreen({Key key, @required this.tunnelId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReminderSelectPage(tunnelId: tunnelId);
  }
}

class ReminderSelectPage extends StatefulWidget {
  ReminderSelectPage({Key key, @required this.tunnelId}) : super(key: key);

  String tunnelId;

  @override
  _ReminderState createState() => _ReminderState(tunnelId);
}

showAlertDialog(BuildContext context, String title, String message) {

  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class _ReminderState extends State<ReminderSelectPage> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0);

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  String tunnelId;

  _ReminderState(this.tunnelId);

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  _selectTime(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  double _convertTimeToDouble(TimeOfDay time) {
    return time.hour + time.minute/60.0;
  }

  bool _validatePhoneNumber(String phone) {
    String pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
    RegExp regExp = new RegExp(pattern);

    return regExp.hasMatch(phone);
  }

  _sendReminder(BuildContext context) async {

    if (phoneController.text.isEmpty) {
      showAlertDialog(context, "Form error", "Missing phone number! 📞❌");
      return;
    }else if (!_validatePhoneNumber(phoneController.text)) {
      showAlertDialog(context, "Form error", "Not a phone number! 📞❌");
      return;
    }

    if (titleController.text.isEmpty) {
      showAlertDialog(context, "Form error", "Missing reminder title! 📜🖊");
      return;
    }

    // Date check
    if (selectedDate.isBefore(DateTime.now().subtract(new Duration(days: 1)))) {
      showAlertDialog(context, "Date error", "Date is set in the past! 📅⏪");
      return;
    }

    // Time check
    if (_convertTimeToDouble(selectedTime) < _convertTimeToDouble(TimeOfDay.now())) {
      showAlertDialog(context, "Time error", "Time is set in the past! ⌚⏪");
      return;
    }

    String dueDate = selectedDate.toString().split(' ')[0] + "T" + selectedTime.toString().substring(10,15);
    final response = await http.post(
      "https://" + tunnelId + ".ngrok.io/reminders",// + tunnelId + "ngrok.io/reminders",
      headers: <String, String> {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String> {
        'name': titleController.text,
        'description': descriptionController.text,
        'dueDate': dueDate,
        'receiverPhoneNumber': phoneController.text,
      }),
    );


    if (response.statusCode == 200) {
      showAlertDialog(context, "Success!", "Reminder sent successfully! ✔");
    }else {
      showAlertDialog(context, "Error", "Oops! Server connection error! ❌");
    }
  }

  @override
  Widget build(BuildContext context) {

    final toField = TextField(
      autofocus: false,
      obscureText: false,
      style: style,
      onEditingComplete: () => FocusScope.of(context).nextFocus(),
      controller: phoneController,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Phone number ...",
        border:
        OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final titleField = TextField(
      autofocus: false,
      obscureText: false,
      style: style,
      onEditingComplete: () => FocusScope.of(context).nextFocus(),
      controller: titleController,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Reminder title ... ",
        border:
        OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final descriptionField = TextField(
      autofocus: false,
      obscureText: false,
      style: style,
      maxLines: 4,
      onEditingComplete: () => FocusScope.of(context).unfocus(),
      controller: descriptionController,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Short description ... ",
        border:
        OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final dateButton = Column(
      //mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          onPressed: () => _selectDate(context), // Refer step 3
          child: Text(
            "${selectedDate.toLocal()}".split(' ')[0],
            style: style,
          ),
          padding: const EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
          color: Colors.greenAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ],
    );

    final timeButton = Column(
      //mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          onPressed: () => _selectTime(context), // Refer step 3
          child: Text(
            "${selectedTime.toString().substring(10,15)}",
            style: style,
          ),
          padding: const EdgeInsets.fromLTRB(37.0, 15.0, 37.0, 15.0),
          color: Colors.greenAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ],
    );

    final sendButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Color(0xff01A0C7),
        child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: () {
              _sendReminder(context);
            },
            child: Text("Send",
              textAlign: TextAlign.center,
              style: style.copyWith(
                  color: Colors.white, fontWeight: FontWeight.bold
              ),
            )
        )
    );

    final backButton = Material(
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
            onPressed: () {
              Navigator.pop(context);
              FocusScope.of(context).unfocus();
            },
            child: Text("Back",
              textAlign: TextAlign.center,
              style: style.copyWith(
                  color: Color(0xff01A0C7), fontWeight: FontWeight.bold
              ),
            )
        )
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Container(
        alignment: Alignment.topLeft,
        child: Container(
          color: Colors.white,
          // alignment: Alignment.topLeft,
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.fromLTRB(30, 50, 30, 20),
                child: SizedBox(
                  height: 50.0,
                  child: Image.asset(
                    "assets/Inside_text.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              // Insert back button here
              // backButton,
              // toField,
              Container(
                alignment: Alignment.topLeft,
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: toField,
              ),
              // titleField,
              SizedBox(height: 30.0),
              Container(
                alignment: Alignment.topLeft,
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: titleField,
              ),
              // descriptionField,
              SizedBox(height: 30.0),
              Container(
                alignment: Alignment.topLeft,
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: descriptionField,
              ),
              SizedBox(height: 30.0),
              Wrap(
                runSpacing: 4.0,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    width: MediaQuery.of(context).size.width * 0.4,
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
                    child: dateButton,
                  ),
                  SizedBox(height: 30.0),
                  Container(
                    alignment: Alignment.topLeft,
                    width: MediaQuery.of(context).size.width * 0.4,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: timeButton,
                  ),
                ],
              ),
              SizedBox(height: 30.0),
              Wrap(
                children: <Widget> [
                  SizedBox(height: 30.0),
                  Container(
                    alignment: Alignment.topLeft,
                    width: MediaQuery.of(context).size.width * 0.4,
                    padding: const EdgeInsets.fromLTRB(20, 0, 6, 10),
                    child: backButton,
                  ),
                  SizedBox(height: 30.0),
                  Container(
                    alignment: Alignment.topLeft,
                    width: MediaQuery.of(context).size.width * 0.4,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: sendButton,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}