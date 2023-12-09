import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weatherapp/models/location.dart';

final locationProvider = NotifierProvider<LocationProvider, LocInfo>(
  LocationProvider.new,
);

class LocationProvider extends Notifier<LocInfo> {
  @override
  LocInfo build() => LocInfo(latitude: 40.193298, longitude: 29.0610);

  /* Check Location Service */
  Future<bool> checkLocationService() async {
    try {
      Location location = Location();

      bool serviceEnabled = false;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /* Update Location */
  Future<void> updateLocation() async {
    try {
      Location location = Location();

      bool serviceEnabled = false;
      PermissionStatus permissionGranted;
      LocationData locationData;

      serviceEnabled = await checkLocationService();

      if (!serviceEnabled) {
        return;
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      locationData = await location.getLocation();

      state = LocInfo(
        latitude: locationData.latitude ?? 0.0,
        longitude: locationData.longitude ?? 0.0,
      );

      return;
    } catch (e) {
      return;
    }
  }
}

googleMap(latitude, longitude) async {
  String url = "https://www.google.com/maps/place/$latitude,$longitude";
  if (!await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.inAppBrowserView,
  )) {
    throw Exception('Could not launch url');
  }
}
