
import 'package:flutter/material.dart';

class MessageInputPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => MessageInputPageState();

}

class MessageInputPageState extends State<MessageInputPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: Center(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Enter upto 200 characters'
            ),
            maxLength: 200,
            onSubmitted: (text){
              Navigator.pop(context, text);
            },
          ),
        )
      )
    );
  }
  
}
