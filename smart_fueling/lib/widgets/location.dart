import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
// import 'package:geocoder/geocoder.dart';
import 'package:location_geocoder/location_geocoder.dart';

// ignore: must_be_immutable
class Locate extends StatefulWidget {
  late Function setMarker;
  late LatLng userLocation;
  Locate({
    Key? key,
    required this.setMarker,
    required this.userLocation,
  }) : super(key: key);

  @override
  State<Locate> createState() => _LocateState();
}

class _LocateState extends State<Locate> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  static const String gapiKey = 'AIzaSyC7bvDC-YbKrrd1Xmwjjd_XIu0SPwkpYrU';

  DetailsResult? fromPosition;
  DetailsResult? toPosition;

  bool toTextFieldVisible = false;
  late FocusNode fromFocusNode;
  late FocusNode toFocusNode;

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    fromFocusNode = FocusNode();
    toFocusNode = FocusNode();

    googlePlace = GooglePlace(gapiKey);
  }

  @override
  void dispose() {
    super.dispose();
    fromFocusNode.dispose();
    toFocusNode.dispose();
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value,
        location:
            LatLon(widget.userLocation.latitude, widget.userLocation.longitude),
        radius: 50000,
        origin:
            LatLon(widget.userLocation.latitude, widget.userLocation.longitude),
        language: 'en',
        // types: 'address',
        locationBias: 'circle');
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  void clearTextField({String textField = 'from'}) {
    if (textField == 'from') {
      setState(() {
        _fromController.text = '';
        _toController.text = '';
        predictions = [];
      });
      toTextFieldVisible = false;
      widget.setMarker(markerType: 'from', markerVisible: false);
    } else if (textField == 'to') {
      setState(() {
        _toController.text = '';
        predictions = [];
      });
    }
    widget.setMarker(markerType: 'to', markerVisible: false);
  }

  @override
  Widget build(BuildContext context) {
    final LocatitonGeocoder geocoder = LocatitonGeocoder(gapiKey);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _fromController,
            focusNode: fromFocusNode,
            decoration: InputDecoration(
                hintText: 'From',
                contentPadding: const EdgeInsets.all(10),
                filled: true,
                fillColor: Colors.white,
                constraints: const BoxConstraints(maxHeight: 50),
                // labelText: 'Starting Location',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffix: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    clearTextField(textField: 'from');
                  },
                )),
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 200), () {
                if (value.isNotEmpty) {
                  toTextFieldVisible = false;
                  autoCompleteSearch(value);
                } else {
                  clearTextField(textField: 'from');
                }
              });
            },
          ),
          const SizedBox(
            height: 5,
          ),
          Visibility(
            visible: toTextFieldVisible,
            child: TextField(
              controller: _toController,
              focusNode: toFocusNode,
              decoration: InputDecoration(
                  hintText: 'Destination',
                  contentPadding: const EdgeInsets.all(10),
                  filled: true,
                  fillColor: Colors.white,
                  constraints: const BoxConstraints(maxHeight: 50),
                  // labelText: 'Enter Destination',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  suffix: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      clearTextField(textField: 'to');
                    },
                  )),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 200), () {
                  if (value.isNotEmpty) {
                    autoCompleteSearch(value);
                  } else {
                    clearTextField(textField: 'to');
                  }
                });
              },
            ),
          ),
          ListView.builder(
            itemBuilder: (context, index) {
              int offset = 0;
              if (index == 0 && fromFocusNode.hasFocus) {
                offset = 1;
                return Container(
                  color: Colors.white,
                  child: ListTile(
                    leading: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                    ),
                    tileColor: Colors.white,
                    title: const Text('Use my current location'),
                    onTap: () async {
                      var addresses = await geocoder
                          .findAddressesFromCoordinates(Coordinates(
                              widget.userLocation.latitude,
                              widget.userLocation.longitude));
                      // var first = addresses.first;
                      setState(() {
                        _fromController.text = addresses.first.addressLine!;
                        predictions = [];
                        toTextFieldVisible = true;
                        toFocusNode.requestFocus();
                      });
                      widget.setMarker(
                          markerPosition: widget.userLocation,
                          markerType: 'from',
                          markerVisible: true);
                    },
                  ),
                );
              } else {
                return Container(
                  color: Colors.white,
                  child: ListTile(
                    tileColor: Colors.white,
                    title: Text(
                        predictions[index - offset].description!.toString()),
                    onTap: () async {
                      final placeId = predictions[index - offset].placeId;
                      final details = await googlePlace.details.get(placeId!);
                      if (details != null &&
                          details.result != null &&
                          mounted) {
                        if (fromFocusNode.hasFocus) {
                          setState(() {
                            fromPosition = details.result;
                            _fromController.text = details.result!.name!;
                            predictions = [];
                            toTextFieldVisible = true;
                            toFocusNode.requestFocus();
                          });
                          widget.setMarker(
                              markerPosition: LatLng(
                                  details.result!.geometry!.location!.lat!,
                                  details.result!.geometry!.location!.lng!),
                              markerType: 'from',
                              markerVisible: true);
                        } else {
                          setState(() {
                            toPosition = details.result;
                            _toController.text = details.result!.name!;
                            predictions = [];
                            FocusScope.of(context).unfocus();
                          });
                          widget.setMarker(
                              markerPosition: LatLng(
                                  details.result!.geometry!.location!.lat!,
                                  details.result!.geometry!.location!.lng!),
                              markerType: 'to',
                              markerVisible: true);
                        }
                      }
                    },
                  ),
                );
              }
            },
            itemCount: predictions.length,
            shrinkWrap: true,
          ),
          TextButton(onPressed: () {}, child: const Text('Go'))
        ],
      ),
    );
  }
}
