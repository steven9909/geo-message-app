import 'package:geolocator/geolocator.dart';

class Location{
  static Future<Position> getCurrentLocation(){
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    return geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }
}
