
import 'package:flutter/material.dart';

class MessageInputPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => MessageInputPageState();

}

class MessageInputPageState extends State<MessageInputPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter any messages upto 200 characters'
          ),
          maxLength: 200,
          onSubmitted: (text){
            Navigator.pop(context, text);
          },
        ),
      ),
    );
  }
  
}
