import 'package:carita/bloc/story/story_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/pref/pref_bloc.dart';
import '../../../routes/page_manager.dart';
import '../../component/empty_widget.dart';
import '../../component/header_widget.dart';
import '../../component/story_item.dart';

class HomeScreen extends StatefulWidget {
  final Function onLoading;
  final Function onLoaded;
  final Function(String storyId) toDetailScreen;
  final Function toCreateStoryScreen;
  final Function toMapsScreen;
  final Function onLogout;
  final Function(String message) onError;

  const HomeScreen({
    Key? key,
    required this.onLoading,
    required this.onLoaded,
    required this.toCreateStoryScreen,
    required this.toMapsScreen,
    required this.toDetailScreen,
    required this.onLogout,
    required this.onError,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController scrollController = ScrollController();

  String? _name;
  String? _accessToken;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<PrefBloc>(context).add(PrefGetLoggedDataEvent());

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        if (BlocProvider.of<StoryBloc>(context).pageItems != null) {
          BlocProvider.of<StoryBloc>(context).add(
              StoryListEvent(accessToken: _accessToken ?? "", location: 0));
        }
      }
    });
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
              _name = state.name;
              _accessToken = state.accessToken;

              BlocProvider.of<StoryBloc>(context).add(
                  StoryListEvent(accessToken: _accessToken ?? "", location: 0));
            }
          },
        ),
      ],
      child: _buildScreen(context),
    );
  }

  _buildScreen(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: scrollController,
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            vertical: 70.0,
            horizontal: 20.0,
          ),
          children: [
            HeaderHomeWidget(
              title: 'Carita',
              descTitle: 'Hello $_name!',
              descSubtitle: 'Explore beautiful stories!',
              onLogout: () => widget.onLogout(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _accessToken != null
                  ? _buildList()
                  : const Center(
                      child: Text(
                        'You are not authorized to access this.',
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => widget.toMapsScreen(),
            child: const Icon(
              Icons.map_rounded,
            ),
          ),
          const SizedBox(
            height: 12.0,
          ),
          FloatingActionButton(
            onPressed: () async {
              final scaffoldMessengerState = ScaffoldMessenger.of(context);
              final pageManager = context.read<PageManager>();
              final storyBloc = BlocProvider.of<StoryBloc>(context);

              widget.toCreateStoryScreen();

              final dataString =
                  await pageManager.waitForResult().then((value) {
                storyBloc
                  ..add(StorySetPageItemsEvent())
                  ..add(StoryListEvent(
                      accessToken: _accessToken ?? "", location: 0));

                return value;
              });

              scaffoldMessengerState.showSnackBar(
                SnackBar(
                  content: Text(
                    dataString,
                  ),
                ),
              );
            },
            child: const Icon(
              Icons.add_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, state) {
        final stories = BlocProvider.of<StoryBloc>(context).listStory;
        if (state is StorySuccessState && stories.isNotEmpty) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              return StoryItem(
                story: stories[index],
                toDetailScreen: (storyId) => widget.toDetailScreen(storyId),
              );
            },
          );
        } else {
          return const EmptyWidget();
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
