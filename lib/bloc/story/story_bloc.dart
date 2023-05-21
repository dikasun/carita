import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../data/repository/story_repository.dart';

part 'story_event.dart';

part 'story_state.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final StoryRepository _storyRepository;

  int? pageItems = 1;
  int sizeItems = 10;

  String? _imagePath;
  XFile? _imageFile;

  String? get imagePath => _imagePath;

  XFile? get imageFile => _imageFile;

  StoryBloc(this._storyRepository) : super(StoryInitialState()) {
    on<StoryListEvent>((event, emit) async {
      if (pageItems == 1) {
        emit(StoryLoadingState());
      }
      try {
        final stories = await _storyRepository.fetchStories(
          event.accessToken,
          pageItems,
          sizeItems,
          event.location,
        );
        if (stories.listStory.length < sizeItems) {
          pageItems = 1;
        } else {
          pageItems = pageItems! + 1;
        }
        emit(StorySuccessState(stories));
      } catch (e) {
        emit(StoryErrorState(e.toString()));
      }
    });

    on<StoryDetailEvent>((event, emit) async {
      emit(StoryLoadingState());
      try {
        final storyDetails = await _storyRepository.fetchStoryDetails(
            event.id, event.accessToken);
        emit(StorySuccessState(storyDetails));
      } catch (e) {
        emit(StoryErrorState(e.toString()));
      }
    });

    on<StoryCreateEvent>((event, emit) async {
      emit(StoryLoadingState());
      try {
        final fileName = event.imageFile.name;
        final bytes = await event.imageFile.readAsBytes();
        final newBytes = await compressImage(bytes);

        final createStory = await _storyRepository.createStory(
          newBytes,
          fileName,
          event.description,
          event.lat,
          event.long,
          event.accessToken,
        );
        emit(StorySuccessState(createStory));
      } catch (e) {
        emit(StoryErrorState(e.toString()));
      }
    });

    on<StorySetImageEvent>((event, emit) async {
      _imagePath = event.imagePath;
      _imageFile = event.imageFile;
      emit(StorySetImageSuccessState(
          imagePath: imagePath, imageFile: imageFile));
    });

    on<StorySetPageItemsEvent>((event, emit) {
      pageItems = 1;
    });
  }

  Future<List<int>> compressImage(List<int> bytes) async {
    int imageLength = bytes.length;
    if (imageLength < 1000000) return bytes;

    Uint8List listBytes = Uint8List.fromList(bytes);
    final img.Image image = img.decodeImage(listBytes)!;
    int compressQuality = 100;
    int length = imageLength;
    List<int> newByte = [];

    do {
      compressQuality -= 10;

      newByte = img.encodeJpg(
        image,
        quality: compressQuality,
      );

      length = newByte.length;
    } while (length > 1000000);

    return newByte;
  }
}
