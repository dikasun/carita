import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lottie/lottie.dart';

import '../../../bloc/pref/pref_bloc.dart';
import '../../../bloc/story/story_bloc.dart';
import '../../component/back_button_widget.dart';
import '../../component/empty_widget.dart';

class DetailScreen extends StatefulWidget {
  final Function onLoading;
  final Function onLoaded;
  final Function onBack;
  final String storyId;
  final Function(String message) onError;

  const DetailScreen({
    Key? key,
    required this.onLoading,
    required this.onLoaded,
    required this.onBack,
    required this.storyId,
    required this.onError,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? _accessToken;

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
        return state is StorySuccessState
            ? ListView(
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
                        onBack: () => widget.onBack(),
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
                            placeholder: (context, url) => Lottie.asset(
                              "assets/lottie/loading.json",
                              repeat: true,
                            ),
                            errorWidget: (context, url, error) => Lottie.asset(
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
                      ],
                    ),
                  ),
                ],
              )
            : const EmptyWidget();
      },
    );
  }
}
