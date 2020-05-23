import 'package:flutter/material.dart';
import '../main.dart';
import 'StatefulWidgets.dart';


class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          child: Text('Welcome to GeoMessage!'),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              createAnimatedRoute(MapPage()),
            );
          },
        ),
      ),
    );
  }
}



