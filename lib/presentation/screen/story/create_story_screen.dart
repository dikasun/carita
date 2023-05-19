import 'dart:io';

import 'package:carita/routes/page_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../bloc/pref/pref_bloc.dart';
import '../../../bloc/story/story_bloc.dart';
import '../../component/back_button_widget.dart';
import '../../component/loading_widget.dart';

class CreateStoryScreen extends StatefulWidget {
  final Function onLoading;
  final Function onLoaded;
  final Function onBack;
  final Function onSend;
  final Function(String message) onError;

  const CreateStoryScreen({
    Key? key,
    required this.onLoading,
    required this.onLoaded,
    required this.onBack,
    required this.onSend,
    required this.onError,
  }) : super(key: key);

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();

  String? accessToken;

  bool validateForm() {
    final FormState? form = _formKey.currentState;
    return (form != null && form.validate());
  }

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

              BlocProvider.of<StoryBloc>(context).add(StorySetImageEvent(
                imagePath: null,
                imageFile: null,
              ));
              context.read<PageManager>().returnData(state.response.message);

              widget.onSend();
            }
          },
        ),
        BlocListener<PrefBloc, PrefState>(
          listener: (context, state) {
            if (state is PrefSuccessState) {
              accessToken = state.accessToken;
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
                const Text(
                  "Create Story",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 48.0,
                horizontal: 20.0,
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
                    BlocBuilder<StoryBloc, StoryState>(
                        builder: (context, state) {
                      if (state is StorySetImageSuccessState) {
                        return state.imagePath == null
                            ? const LoadingWidget()
                            : _showImage(state.imagePath);
                      } else {
                        return const LoadingWidget();
                      }
                    }),
                    const SizedBox(
                      height: 18.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FilledButton(
                          onPressed: () => _onGalleryView(context),
                          child: const Text("Gallery"),
                        ),
                        FilledButton(
                          onPressed: () => _onCameraView(context),
                          child: const Text("Camera"),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 18.0,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      autofocus: false,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: 'Description',
                        labelText: 'Description',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                      ),
                      validator: (value) {
                        return (value != null && value.isNotEmpty)
                            ? null
                            : 'Description cannot be empty.';
                      },
                    ),
                    const SizedBox(
                      height: 64.0,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () =>
                                validateForm() ? _onUpload() : null,
                            child: const Text(
                              'Submit',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onUpload() async {
    final ScaffoldMessengerState scaffoldMessengerState =
        ScaffoldMessenger.of(context);
    final storyBloc = BlocProvider.of<StoryBloc>(context);
    final imagePath = storyBloc.imagePath;
    final imageFile = storyBloc.imageFile;

    if (imagePath == null || imageFile == null) {
      scaffoldMessengerState.showSnackBar(
        const SnackBar(
          content: Text(
            "Image cannot be empty.",
          ),
        ),
      );
      return;
    }

    storyBloc.add(StoryCreateEvent(
      imageFile: imageFile,
      description: _descriptionController.text,
      lat: null,
      long: null,
      accessToken: accessToken!,
    ));
  }

  _onGalleryView(BuildContext context) async {
    final storyBloc = BlocProvider.of<StoryBloc>(context);
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      storyBloc.add(StorySetImageEvent(
        imagePath: pickedFile.path,
        imageFile: pickedFile,
      ));
    }
  }

  _onCameraView(BuildContext context) async {
    final storyBloc = BlocProvider.of<StoryBloc>(context);
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      storyBloc.add(StorySetImageEvent(
        imagePath: pickedFile.path,
        imageFile: pickedFile,
      ));
    }
  }

  Widget _showImage(String? imagePath) {
    return Image.file(
      File(imagePath.toString()),
      fit: BoxFit.contain,
    );
  }
}
