import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:async/async.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

import '../Location.dart';
import '../main.dart';
import '../Database.dart';


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
            centerWidget
          ]
        ),
      )
    );
  }

}



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

class MapPage extends StatefulWidget {

  Position initialPosition;

  MapPage(Position initialPosition){
    this.initialPosition = initialPosition;
  }

  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {

  MapController mapController;
  Position currentPosition;
  RestartableTimer locationTimer;
  List<LatLng> markersPosition;
  Stream<List<DocumentSnapshot>> stream;
  Database db;

  BehaviorSubject<LatLng> positionController = BehaviorSubject<LatLng>();

  @override
  void initState(){
    mapController = MapController();

    db = new Database();

    locationTimer = new RestartableTimer(Duration(seconds: 30),(){
      Location.getCurrentLocation().then((pos){
        currentPosition = pos;
        positionController.add(new LatLng(currentPosition.latitude,currentPosition.longitude));
        locationTimer.reset();
      }).catchError((err){
        currentPosition = null;
      });
    });

    stream = positionController.switchMap((pos){
      return db.getNearbyMessages(pos.latitude, pos.longitude, 20);
    });

    stream.listen((event) {
      updateMarkers(event);
    });

    if(markersPosition == null){
      markersPosition = new List<LatLng>();
    }
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
    positionController.close();
  }

  void updateMarkers(List<DocumentSnapshot> list){

    List<LatLng> newMarkersPosition = new List<LatLng>();
    list.forEach((document){
      GeoPoint point = document.data['coordinate']['geopoint'];
      newMarkersPosition.add(new LatLng(point.latitude,point.longitude));
    });
    setState(() {
      markersPosition = newMarkersPosition;
    });

  }

  void centerToCurrentPosition(){
    mapController.move(new LatLng(currentPosition.latitude,currentPosition.longitude),17);
  }

  void navigateAndDisplayMessagePage(BuildContext context) async{
    var result = await Navigator.push(context, createAnimatedRoute(MessageInputPage()));
    db.addLocationToDb(currentPosition.latitude, currentPosition.longitude, result);
  }

  Widget build(BuildContext context) {
  
    var markers = markersPosition.map((latlng){
      return Marker(
        width: 50,
        height: 50,
        point: latlng,
        builder: (ctx) => Container(
          child: Material(
            color: Colors.transparent,
            child: IconButton(
              icon: Icon(Icons.location_on),
              color: Colors.white,  
              onPressed: (){
                db.getMessage(latlng.latitude, latlng.longitude).then((value){
                  if(value.documents.length > 0){
                    String msg = value.documents[0].data["message"];
                    db.deleteMessage(value.documents[0]).then((placeholder){
                        markersPosition.removeWhere((marker){
                          return marker.latitude == latlng.latitude && marker.longitude == latlng.longitude;
                        });
                        Navigator.push(context,createAnimatedRoute(MessageOutputPage(displayMessage:msg)));
                    });
                  }
                });
              }
            )
          )
        )
      );
    }).toList();

    return Stack(
      children: <Widget>[
        Align(alignment: Alignment.center, child: new FlutterMap(
              
              mapController: mapController,
              options: new MapOptions(
                center: new LatLng(0, 0),
                zoom: 13.0,
              ),
              layers: [
                new TileLayerOptions(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']
                ),
                MarkerLayerOptions(markers: markers)
              ],
            )
          ),
          Align(alignment: Alignment.bottomCenter, child: new FlatButton(onPressed: centerToCurrentPosition, child: Text("Center To Me"))),
          Align(alignment: Alignment.topRight, child: Material(
            color: Colors.transparent,
            child: IconButton(
              icon: Icon(Icons.message),
              color: Colors.white,  
              onPressed: (){
                if(currentPosition != null){
                  navigateAndDisplayMessagePage(context);
                }
              }
            )
          )
        )
      ] 
    );
  }
}