import 'dart:async';
import 'dart:ffi';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';

class Locate extends StatefulWidget {
  late Function setMarker;
  Locate({
    Key? key,
    required this.setMarker,
  }) : super(key: key);

  @override
  State<Locate> createState() => _LocateState();
}

class _LocateState extends State<Locate> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

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
    // TODO: implement initState
    super.initState();

    fromFocusNode = FocusNode();
    toFocusNode = FocusNode();

    String gapiKey = 'AIzaSyC7bvDC-YbKrrd1Xmwjjd_XIu0SPwkpYrU';
    googlePlace = GooglePlace(gapiKey);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    fromFocusNode.dispose();
    toFocusNode.dispose();
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value,
        location: LatLon(80.273495, 13.082990),
        radius: 50000,
        origin: LatLon(80.273495, 13.082990),
        language: 'en',
        types: 'address',
        locationBias: 'circle');
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _fromController,
            focusNode: fromFocusNode,
            decoration: InputDecoration(
                hintText: 'From',
                contentPadding: EdgeInsets.all(10),
                filled: true,
                fillColor: Colors.white,
                constraints: BoxConstraints(maxHeight: 50),
                // labelText: 'Starting Location',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                if (value.isNotEmpty) {
                  autoCompleteSearch(value);
                } else {
                  _toController.text = '';
                  setState(() {
                    predictions = [];
                  });
                }
              });
            },
          ),
          SizedBox(
            height: 5,
          ),
          Visibility(
            visible: toTextFieldVisible,
            child: TextField(
              controller: _toController,
              focusNode: toFocusNode,
              decoration: InputDecoration(
                  hintText: 'Destination',
                  contentPadding: EdgeInsets.all(10),
                  filled: true,
                  fillColor: Colors.white,
                  constraints: BoxConstraints(maxHeight: 50),
                  // labelText: 'Enter Destination',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 200), () {
                  if (value.isNotEmpty) {
                    autoCompleteSearch(value);
                  } else {
                    _toController.text = '';
                    setState(() {
                      predictions = [];
                    });
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
                    leading: Icon(
                      Icons.my_location,
                      color: Colors.blue,
                    ),
                    tileColor: Colors.white,
                    title: Text('Use my current location'),
                    onTap: () async {},
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
                            _fromController.text =
                                details.result!.formattedAddress!;
                            predictions = [];
                            toTextFieldVisible = true;
                            toFocusNode.requestFocus();
                          });
                          widget.setMarker(
                              markerPosition: LatLng(
                                  details.result!.geometry!.location!.lat!,
                                  details.result!.geometry!.location!.lng!),
                              markerType: 'from',
                              markerSelected: true);
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
                              markerSelected: true);
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
          TextButton(onPressed: () {}, child: Text('Go'))
        ],
      ),
    );
  }
}
