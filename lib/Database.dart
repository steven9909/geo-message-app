import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'database_limit.dart';

class Database{

  Geoflutterfire _dbGeo;
  DatabaseLimiter limiter;

  Database(){
    _dbGeo = Geoflutterfire();
    limiter = new DatabaseLimiter();
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
    if(limiter.canSubmitToDb()){
      Firestore.instance.collection("Location").add({
        "message" : message,
        "coordinate" : _dbGeo.point(latitude: latitude, longitude: longitude).data
      });
      limiter.submit();
    }
  }
  
}