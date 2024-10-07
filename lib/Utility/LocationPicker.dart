import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationPicker extends StatefulWidget {
  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  String _selectedLocation = "Tag Location";
  LatLng? _pickedLocation;
  final TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = [];
  final String apiKey = 'AIzaSyBdmLSrq0OuQob_ZvkV6zh9sVS2FmnYo4o';
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: 'Search Location'),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _fetchSuggestions(value);
                } else {
                  setState(() {
                    _suggestions.clear();
                  });
                }
              },
            ),
            if (_suggestions.isNotEmpty)
              Container(
                height: 80,
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_suggestions[index]),
                      onTap: () {
                        _searchController.text = _suggestions[index];
                        _setLocationFromSuggestion(_suggestions[index]);
                        _suggestions.clear();
                      },
                    );
                  },
                ),
              ),
            SizedBox(height: 5),
            Container(
              height: 450,
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(37.4276, -122.1697),
                  zoom: 14,
                ),
                markers: _markers,
                onTap: (LatLng location) {
                  _getAddressFromLatLng(location);
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_pickedLocation != null) {
              _selectedLocation = _searchController.text;
              Navigator.of(context).pop({
                'latitude': _pickedLocation!.latitude,
                'longitude': _pickedLocation!.longitude,
                'address': _selectedLocation,
              });
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Text('Confirm'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }

  Future<void> _fetchSuggestions(String query) async {
    final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      setState(() {
        _suggestions = List<String>.from(result['predictions'].map((pred) => pred['description']));
      });
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['results'].isNotEmpty) {
        final address = result['results'][0]['formatted_address'];
        setState(() {
          _pickedLocation = location;
          _searchController.text = address;
          _markers.clear();
          _markers.add(Marker(
            markerId: MarkerId("pickedLocation"),
            position: location,
            icon: BitmapDescriptor.defaultMarker,
          ));
          _moveCameraToLocation(location);
        });
      }
    } else {
      throw Exception('Failed to load address');
    }
  }

  Future<void> _setLocationFromSuggestion(String suggestion) async {
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(suggestion)}&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['results'].isNotEmpty) {
        final location = result['results'][0]['geometry']['location'];
        setState(() {
          _pickedLocation = LatLng(location['lat'], location['lng']);
          _searchController.text = result['results'][0]['formatted_address'];
          _markers.clear();
          _markers.add(Marker(
            markerId: MarkerId("pickedLocation"),
            position: _pickedLocation!,
            icon: BitmapDescriptor.defaultMarker,
          ));
          _moveCameraToLocation(_pickedLocation!);
        });
        print("Selected location: ${_pickedLocation}");
      } else {
        print("No results found for the suggestion.");
      }
    } else {
      print("Error fetching location: ${response.statusCode}");
      throw Exception('Failed to load location');
    }
  }

  void _moveCameraToLocation(LatLng location) {
    if (_mapController != null) {
      print("Moving camera to: $location");
      _mapController!.animateCamera(CameraUpdate.newLatLng(location));
    } else {
      print("Map controller is null, cannot move camera.");
    }
  }
}
