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
  final Function(String storyId) toDetailScreen;
  final Function toCreateStoryScreen;
  final Function onLogout;
  final Function(String message) onError;

  const HomeScreen({
    Key? key,
    required this.toCreateStoryScreen,
    required this.toDetailScreen,
    required this.onLogout,
    required this.onLoading,
    required this.onError,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _name;
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
              Navigator.of(context).pop();

              widget.onError(state.message);
            } else if (state is StorySuccessState) {
              Navigator.of(context).pop();
            }
          },
        ),
        BlocListener<PrefBloc, PrefState>(
          listener: (context, state) {
            if (state is PrefSuccessState) {
              _name = state.name;
              _accessToken = state.accessToken;

              BlocProvider.of<StoryBloc>(context)
                  .add(StoryListEvent(accessToken: _accessToken ?? ""));
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final scaffoldMessengerState = ScaffoldMessenger.of(context);
          final pageManager = context.read<PageManager>();

          widget.toCreateStoryScreen();

          final dataString = await pageManager.waitForResult().then((value) {
            BlocProvider.of<StoryBloc>(context)
                .add(StoryListEvent(accessToken: _accessToken ?? ""));

            return value;
          });

          if (dataString != "popped") {
            scaffoldMessengerState.showSnackBar(
              SnackBar(
                content: Text(
                  dataString,
                ),
              ),
            );
          }
        },
        child: const Icon(
          Icons.add_rounded,
        ),
      ),
    );
  }

  Widget _buildList() {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, state) {
        return state is StorySuccessState && state.response.listStory.length > 0
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.response.listStory.length,
                itemBuilder: (context, index) {
                  var story = state.response.listStory[index];
                  return StoryItem(
                    story: story,
                    toDetailScreen: (storyId) async {
                      final pageManager = context.read<PageManager>();

                      widget.toDetailScreen(storyId);

                      await pageManager.waitForResult().then((value) {
                        BlocProvider.of<StoryBloc>(context)
                            .add(StoryListEvent(accessToken: _accessToken ?? ""));
                      });
                    },
                  );
                },
              )
            : const EmptyWidget();
      },
    );
  }
}
