import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Database{

  Geoflutterfire _dbGeo;

  Database(){
    _dbGeo = Geoflutterfire();
  }

  Future<Position> getCurrentLocation(){
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    return geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  Stream<List<DocumentSnapshot>> getNearbyMessages(double curLatitude, double curLongitude, double radius){
    GeoFirePoint center = _dbGeo.point(latitude: curLatitude, longitude: curLongitude);
    
    return _dbGeo.collection(collectionRef: Firestore.instance.collection("Location")).within(center: center, radius:radius, field: 'coordinate');
    
  }

  Future<void> deleteMessage(DocumentSnapshot documentToBeDeleted){
    return Firestore.instance.collection("Location").document(documentToBeDeleted.documentID).delete();
  }

  Future<QuerySnapshot> getMessage(double latitude, double longitude){
    return Firestore.instance.collection("Location").where("coordinate.geopoint",isEqualTo: GeoPoint(latitude,longitude)).getDocuments();
  }

  void addLocationToDb(double latitude, double longitude, String message){
    Firestore.instance.collection("Location").add({
      "message" : message,
      "coordinate" : _dbGeo.point(latitude: latitude, longitude: longitude).data
    });
  }
  
}