part of 'story_bloc.dart';

abstract class StoryState extends Equatable {}

class StoryInitialState extends StoryState {
  @override
  List<Object?> get props => [];
}

class StoryLoadingState extends StoryState {
  @override
  List<Object?> get props => [];
}

class StorySuccessState extends StoryState {
  final dynamic response;

  StorySuccessState(this.response);

  @override
  List<Object?> get props => [response];
}

class StorySetImageSuccessState extends StoryState {
  final String? imagePath;
  final XFile? imageFile;

  StorySetImageSuccessState({required this.imagePath, required this.imageFile});

  @override
  List<Object?> get props => [imagePath, imageFile];
}

class StoryErrorState extends StoryState {
  final String message;

  StoryErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
