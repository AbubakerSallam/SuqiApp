// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:suqi/utilities/storage.dart';
import '../views/main/customer/customer_bottomNav.dart';
import '/constants/colors.dart';
import 'package:suqi/models/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/map-home';
  const MapScreen({
    this.latitude,
    this.longitude,
    super.key,
  });
  final double? latitude;
  final double? longitude;
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _isLoading = false;
  final store = GetStorage();
  final Completer<GoogleMapController> _controller = Completer();
  LocationData? _currentPosition;
  LatLng? _latLong;
  bool _locating = false;
  geocoding.Placemark? _placeMark;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(13.5795, 44.0209),
    zoom: 14.0,
  );
  @override
  void initState() {
    super.initState();
    if (widget.longitude != null) {
      _isLoading = true;
      _fetchLocationFromFirebase();
    } else {
      _getUserLocation();
    }
  }

  Future<void> _fetchLocationFromFirebase() async {
    try {
      var latitude = widget.latitude!.toDouble();
      var longitude = widget.longitude!.toDouble();

      // var latitude = 13.5795;
      // var longitude = 44.0209;

      setState(() {
        _latLong = LatLng(latitude, longitude);
        _isLoading = false;
      });

      if (_latLong != null) {
        _goToCurrentPosition(_latLong!);
      } else {
        _isLoading = false;
      }
    } catch (e) {
      print('Error fetching location: $e');
      setState(() {
        _isLoading = false;
      });
    } finally {
      _isLoading = false;
    }
    _isLoading = false;
  }

  Future<LocationData> _getLocationPermission() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return Future.error('Service not enabled');
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return Future.error('Permission Denied');
      }
    }

    locationData = await location.getLocation();
    return locationData;
  }

  _getUserLocation() async {
    _currentPosition = await _getLocationPermission();
    _goToCurrentPosition(
        LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!));
  }

  getUserAddress() async {
    try {
      List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(_latLong!.latitude, _latLong!.longitude);
      setState(() {
        _placeMark = placemarks.first;
      });
    } catch (e) {
      // showSnackBar('حدث خطأ ما: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 3), // Set a duration for the SnackBar
        action: SnackBarAction(
          onPressed: () => ScaffoldMessenger.of(context)
              .hideCurrentSnackBar(), // Dismiss the SnackBar
          label: 'إلغاء',
          textColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: litePrimary,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.grey,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return SafeArea(
      child: Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * .75,
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey))),
                          child: Stack(
                            children: [
                              GoogleMap(
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                                compassEnabled: false,
                                mapType: MapType.normal,
                                initialCameraPosition: _kGooglePlex,
                                onMapCreated: (GoogleMapController controller) {
                                  _controller.complete(controller);
                                },
                                onCameraMove: (CameraPosition position) {
                                  setState(() {
                                    _locating = true;
                                    _latLong = position.target;
                                  });
                                },
                                onCameraIdle: () {
                                  setState(() {
                                    _locating = false;
                                  });
                                  getUserAddress();
                                },
                              ),
                              const Align(
                                alignment: Alignment.center,
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.black12,
                                  child: Icon(
                                    Icons.location_on,
                                    size: 40,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.home,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const CustomerBottomNav(
                                        currentPageIndex: 0,
                                      ),
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              _placeMark != null
                                  //  && widget.latitude == null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _locating
                                              ? 'Locating...'
                                              : _placeMark!.thoroughfare ??
                                                  _placeMark!.locality!,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          _placeMark!.subThoroughfare != null
                                              ? '${_placeMark!.subThoroughfare!}, ${_placeMark!.thoroughfare!}'
                                              : _placeMark!.thoroughfare ??
                                                  _placeMark!.locality!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Row(
                                          children: [
                                            Text('${_placeMark!.locality!}, '),
                                            Text(_placeMark!
                                                        .subAdministrativeArea !=
                                                    null
                                                ? '${_placeMark!.subAdministrativeArea!}, '
                                                : ''),
                                          ],
                                        ),
                                        Text(
                                            '${_placeMark!.administrativeArea!}, ${_placeMark!.country!}, ${_placeMark!.postalCode!}')
                                      ],
                                    )
                                  : Container(),
                              const SizedBox(
                                height: 10,
                              ),
                              widget.latitude == null
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              padding: const EdgeInsets.all(15),
                                            ),
                                            onPressed: () async {
                                              String subLocal =
                                                  '${_placeMark!.subLocality}, ';
                                              String locality =
                                                  '${_placeMark!.locality}, ';
                                              String adminArea =
                                                  '${_placeMark!.administrativeArea}, ';
                                              String subAdminArea =
                                                  '${_placeMark!.subAdministrativeArea}, ';
                                              String country =
                                                  '${_placeMark!.country}, ';
                                              String pin =
                                                  '${_placeMark!.postalCode}, ';
                                              String address =
                                                  '$subLocal$locality$adminArea$subAdminArea$country$pin';
                                              var storage = SLocalStorage();
                                              storage.saveData(
                                                  'address', address);
                                              if (_latLong != null) {
                                                await saveLocationToFirebase(
                                                    _latLong!);
                                              }
                                              // store.write('address', address);
                                              if (mounted) {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        const CustomerBottomNav(
                                                      currentPageIndex: 0,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text(
                                              'تأكيد العنوان',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink()
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _goToCurrentPosition(LatLng latlng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(latlng.latitude, latlng.longitude),
        // tilt: 59.440717697143555,
        zoom: 14.4746)));
  }

  Future<void> saveLocationToFirebase(LatLng latLng) async {
    if (currentUserId != null) {
      FirebaseFirestore.instance
          .collection('customers')
          .doc(currentUserId)
          .update({
        'latitude': latLng.latitude,
        'longitude': latLng.longitude,
      });
    }
  }
}
