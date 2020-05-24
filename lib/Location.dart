import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class Location{
  static Future<Position> getCurrentLocation(){
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    return geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }
}