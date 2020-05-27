import 'package:flutter/material.dart';

class MessageOutputPage extends StatefulWidget{

  final String displayMessage;
  MessageOutputPage({this.displayMessage});

  @override 
  State<StatefulWidget> createState() => MessageOutputPageState(); 
}

class MessageOutputPageState extends State<MessageOutputPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message')
      ),
      body: Center(
        child: Text(
          widget.displayMessage
        )
      ),
    );
  }

}