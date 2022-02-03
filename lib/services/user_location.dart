import 'package:geolocator/geolocator.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:flutter_geocoder/model.dart';

Future<String?>? getUserLocation() async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  print(position);

  final coordinates = new Coordinates(position.latitude, position.longitude);
  final addresses =
      await Geocoder.local.findAddressesFromCoordinates(coordinates);
  final first = addresses.first;
  print(
      "${first.featureName} : ${first.addressLine} : ${first.subLocality} : ${first.locality} : ${first.adminArea} : ${first.countryName}");

  if (first.locality == null) {
    return first.addressLine;
  } else
    return first.locality;
}
