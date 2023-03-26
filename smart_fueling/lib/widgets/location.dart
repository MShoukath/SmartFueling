import 'dart:async';
import 'package:location/location.dart' as loc;
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';

class Locate extends StatefulWidget {
  const Locate({Key? key}) : super(key: key);

  @override
  State<Locate> createState() => _LocateState();
}

class _LocateState extends State<Locate> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  DetailsResult? fromPosition;
  DetailsResult? toPosition;

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
    var result = await googlePlace.autocomplete.get(value);
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
          TextField(
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
          ListView.builder(
            itemBuilder: (context, index) {
              return Container(
                color: Colors.white,
                child: ListTile(
                  tileColor: Colors.white,
                  title: Text(predictions[index].description!.toString()),
                  onTap: () async {
                    final placeId = predictions[index].placeId;
                    final details = await googlePlace.details.get(placeId!);
                    if (details != null && details.result != null && mounted) {
                      if (fromFocusNode.hasFocus) {
                        setState(() {
                          fromPosition = details.result;
                          _fromController.text = details.result!.name!;
                          predictions = [];
                          toFocusNode.requestFocus();
                        });
                      } else {
                        setState(() {
                          toPosition = details.result;
                          _toController.text = details.result!.name!;
                          predictions = [];
                          FocusScope.of(context).unfocus();
                        });
                      }
                    }
                  },
                ),
              );
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
