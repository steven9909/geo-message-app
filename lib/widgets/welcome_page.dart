import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../location.dart';
import '../main.dart';
import 'map_page.dart';

class WelcomePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => WelcomeState();
}

class WelcomeState extends State<WelcomePage>{

  String _displayMessage;
  Position _currentPosition;

  @override
  void initState(){

    _displayMessage = "Welcome to GeoMessage.\nPlease wait while we attempt to locate you!";
    setAndGetLocation();

    super.initState();
  }

  void setAndGetLocation(){
    Location.getCurrentLocation().then((position){
      setState(() {
        _currentPosition = position;
        _displayMessage = "Click the button below to get started!";
      });
    }).catchError((error){
      setState(() {
        _currentPosition = null;
        _displayMessage = "We couldn't get your location. Please try again later.";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    
    var centerWidget;

    if(_currentPosition == null){
      centerWidget = new CircularProgressIndicator();
    }
    else {
      centerWidget = new RaisedButton(child: new Text("Proceed", style: new TextStyle(color: Colors.lightBlue)), 
        shape: RoundedRectangleBorder(borderRadius:  BorderRadius.circular(18.0), side: BorderSide(color: Colors.white)), 
        onPressed: (){
          Navigator.pushReplacement(context, createAnimatedRoute(new MapPage(_currentPosition)));
        }
      );
    }

    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget> [
            Text(_displayMessage,style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
            SizedBox(height:5),
            centerWidget
          ]
        ),
      )
    );
  }

}




