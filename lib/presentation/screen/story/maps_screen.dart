import 'package:carita/common/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../bloc/pref/pref_bloc.dart';
import '../../../bloc/story/story_bloc.dart';
import '../../../data/models/story_response.dart';
import '../../component/back_button_widget.dart';

class MapsScreen extends StatefulWidget {
  final Function onLoading;
  final Function onLoaded;
  final Function(BuildContext context) onBack;
  final double? latitude;
  final double? longitude;
  final bool isStoryMaps;
  final Function(String message) onError;

  const MapsScreen({
    Key? key,
    required this.onLoading,
    required this.onLoaded,
    required this.onBack,
    required this.latitude,
    required this.longitude,
    required this.isStoryMaps,
    required this.onError,
  }) : super(key: key);

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final center = const LatLng(-6.8957473, 107.6337669);
  late GoogleMapController _mapController;
  final Set<Marker> markers = {};
  String address = "";
  bool showAddress = false;

  String? _accessToken;

  @override
  void initState() {
    super.initState();

    if (widget.isStoryMaps) {
      BlocProvider.of<PrefBloc>(context).add(PrefGetLoggedDataEvent());
    }

    if (widget.latitude != null && widget.longitude != null) {
      _defineMarker(
          widget.latitude.toString(),
          LatLng(
            widget.latitude!,
            widget.longitude!,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StoryBloc, StoryState>(
          listener: (context, state) {
            if (state is StoryLoadingState) {
              widget.onLoading();
            } else if (state is StoryErrorState) {
              widget.onLoaded();
              widget.onError(state.message);
            } else if (state is StorySuccessState) {
              widget.onLoaded();

              final List<ListStory> listStory = state.response.listStory;
              List<LatLng> latLngList = [];

              for (var story in listStory) {
                if (story.lat != null && story.lon != null) {
                  _defineMarker(story.id, LatLng(story.lat!, story.lon!));
                  latLngList.add(LatLng(story.lat!, story.lon!));
                }
              }

              final bound = boundsFromLatLngList(latLngList);
              _mapController.animateCamera(
                CameraUpdate.newLatLngBounds(bound, 50),
              );
            }
          },
        ),
        BlocListener<PrefBloc, PrefState>(
          listener: (context, state) {
            if (state is PrefSuccessState) {
              _accessToken = state.accessToken;

              BlocProvider.of<StoryBloc>(context).add(
                  StoryListEvent(accessToken: _accessToken ?? "", location: 1));
            }
          },
        ),
      ],
      child: _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            GoogleMap(
              markers: markers,
              initialCameraPosition: CameraPosition(
                zoom: 18,
                target: widget.latitude != null && widget.longitude != null
                    ? LatLng(
                        widget.latitude!,
                        widget.longitude!,
                      )
                    : center,
              ),
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                });
              },
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.symmetric(
                  vertical: 70.0,
                  horizontal: 20.0,
                ),
                decoration: const BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BackButtonWidget(
                      onBack: () => widget.onBack(context),
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    const Flexible(
                      child: Text(
                        "Maps",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            showAddress
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.all(18.0),
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 48.0),
                      decoration: const BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(12.0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Address",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 24.0,
                                ),
                                Text(
                                  address,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(
                                  height: 24.0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  void _defineMarker(String markerId, LatLng latLng) async {
    final address = await _getMapAddress(LatLng(
      latLng.latitude,
      latLng.longitude,
    ));
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: latLng,
      onTap: () async {
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 18),
        );
        // Future.delayed(const Duration(seconds: 1)).then((_) => _getAddress(latLng));
        setState(() {
          this.address = address;
          showAddress = true;
        });
      },
    );
    setState(() {
      markers.add(marker);
    });
  }

  Future<String> _getMapAddress(LatLng latLng) async {
    final info =
        await geo.placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    final place = info[0];
    final address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

    return address;
  }
}
