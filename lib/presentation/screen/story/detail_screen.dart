import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as lottie;

import '../../../bloc/pref/pref_bloc.dart';
import '../../../bloc/story/story_bloc.dart';
import '../../component/back_button_widget.dart';
import '../../component/empty_widget.dart';

class DetailScreen extends StatefulWidget {
  final Function onLoading;
  final Function onLoaded;
  final Function(BuildContext context) onBack;
  final String storyId;
  final Function(String message) onError;
  final Function(double lat, double long) toMapScreen;

  const DetailScreen({
    Key? key,
    required this.onLoading,
    required this.onLoaded,
    required this.onBack,
    required this.storyId,
    required this.onError,
    required this.toMapScreen,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? _accessToken;

  late GoogleMapController _mapController;
  final Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();

    BlocProvider.of<PrefBloc>(context).add(PrefGetLoggedDataEvent());
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
            }
          },
        ),
        BlocListener<PrefBloc, PrefState>(
          listener: (context, state) {
            if (state is PrefSuccessState) {
              _accessToken = state.accessToken;

              BlocProvider.of<StoryBloc>(context).add(StoryDetailEvent(
                  id: widget.storyId, accessToken: _accessToken ?? ""));
            }
          },
        ),
      ],
      child: Scaffold(
        body: SingleChildScrollView(
          child: _accessToken != null
              ? _buildDetail()
              : const Center(
                  child: Text(
                    'You are not authorized to access this.',
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDetail() {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, state) {
        if (state is StorySuccessState) {
          LatLng? detailPosition;
          if (state.response.story.lat != null &&
              state.response.story.lon != null) {
            detailPosition =
                LatLng(state.response.story.lat, state.response.story.lon);
            _defineMarker(state.response.story.id, detailPosition);
          }
          return ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              vertical: 70.0,
              horizontal: 20.0,
            ),
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BackButtonWidget(
                    onBack: () => widget.onBack(context),
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  Flexible(
                    child: Text(
                      state.response.story.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 48.0,
                  horizontal: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        cacheKey: state.response.story.id,
                        imageUrl: state.response.story.photoUrl,
                        placeholder: (context, url) => lottie.Lottie.asset(
                          "assets/lottie/loading.json",
                          repeat: true,
                        ),
                        errorWidget: (context, url, error) =>
                            lottie.Lottie.asset(
                          "assets/lottie/error.json",
                          repeat: true,
                        ),
                        cacheManager: CacheManager(
                          Config(
                            state.response.story.id,
                            stalePeriod: const Duration(
                              minutes: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    Text(
                      state.response.story.description,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    const SizedBox(
                      height: 36.0,
                    ),
                    detailPosition != null
                        ? Column(
                            children: [
                              SizedBox(
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                child: GoogleMap(
                                  markers: markers,
                                  initialCameraPosition: CameraPosition(
                                    zoom: 18,
                                    target: detailPosition,
                                  ),
                                  onMapCreated: (controller) {
                                    setState(() {
                                      _mapController = controller;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 18.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  FilledButton(
                                    onPressed: () => widget.toMapScreen(
                                        state.response.story.lat,
                                        state.response.story.lon),
                                    child: const Text(
                                      'Expand Maps',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : const SizedBox(
                            height: 24.0,
                          ),
                    const SizedBox(
                      height: 36.0,
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return const EmptyWidget();
        }
      },
    );
  }

  void _defineMarker(String markerId, LatLng latLng) async {
    final address = await _getMapAddress(latLng);
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: latLng,
      infoWindow: InfoWindow(title: "Location", snippet: address),
      onTap: () async {
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 18),
        );
        await Future.delayed(const Duration(seconds: 1));
        _mapController.showMarkerInfoWindow(MarkerId(markerId));
      },
    );
    setState(() {
      markers.clear();
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
