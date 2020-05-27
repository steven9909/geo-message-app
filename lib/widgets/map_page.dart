import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:async/async.dart';
import 'package:rxdart/rxdart.dart';

import '../database.dart';
import '../location.dart';
import '../main.dart';
import 'messageinput_page.dart';
import 'messageoutput_page.dart';

class MapPage extends StatefulWidget {

  final Position initialPosition;

  MapPage({this.initialPosition});

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

    currentPosition = widget.initialPosition;

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
              iconSize: 30,
              color: Colors.blue,  
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
                center: new LatLng(currentPosition.latitude, currentPosition.longitude),
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
          Align(alignment: Alignment.bottomCenter, child: new FlatButton(color: Colors.blue.withOpacity(0.5), 
            onPressed: centerToCurrentPosition, 
            shape: RoundedRectangleBorder(borderRadius:  BorderRadius.circular(18.0), side: BorderSide(color: Colors.white)),
            child: Text("Center To Me", style: TextStyle(color: Colors.white)))),
          Align(alignment: Alignment.topRight, child: Container(
            margin: EdgeInsets.only(top: 10),
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: Icon(Icons.message),
                iconSize: 30,
                color: Colors.lightBlueAccent,  
                onPressed: (){
                  if(currentPosition != null){
                    navigateAndDisplayMessagePage(context);
                  }
                }
              )
            )
          )
        )
      ] 
    );
  }
}