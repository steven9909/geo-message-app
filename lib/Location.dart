import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class Location{

  static Geoflutterfire geo = Geoflutterfire();

  static Future<Position> getCurrentLocation(){
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    return geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  static Stream<List<DocumentSnapshot>> getNearbyMessages(double curLatitude, double curLongitude, double radius){
    GeoFirePoint center = geo.point(latitude: curLatitude, longitude: curLongitude);
    
    return geo.collection(collectionRef: Firestore.instance.collection("Location")).within(center: center, radius:radius, field: 'coordinate');
    
  }

  static Future<void> deleteMessage(DocumentSnapshot documentToBeDeleted){
    return Firestore.instance.collection("Location").document(documentToBeDeleted.documentID).delete();
  }

  static Future<QuerySnapshot> getMessage(double latitude, double longitude){
    return Firestore.instance.collection("Location").where("coordinate.geopoint",isEqualTo: GeoPoint(latitude,longitude)).getDocuments();
  }

  static void addLocationToDb(double latitude, double longitude, String message){
    Firestore.instance.collection("Location").add({
      "message" : message,
      "coordinate" : geo.point(latitude: latitude, longitude: longitude).data
    });
  }

}