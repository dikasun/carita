part of 'story_bloc.dart';

abstract class StoryEvent extends Equatable {}

class StoryListEvent extends StoryEvent {
  final String accessToken;
  final int location;

  StoryListEvent({required this.accessToken, required this.location});

  @override
  List<Object?> get props => [];
}

class StoryDetailEvent extends StoryEvent {
  final String id;
  final String accessToken;

  StoryDetailEvent({required this.id, required this.accessToken});

  @override
  List<Object?> get props => [];
}

class StoryCreateEvent extends StoryEvent {
  final XFile imageFile;
  final String description;
  final double? lat;
  final double? long;
  final String accessToken;

  StoryCreateEvent({
    required this.imageFile,
    required this.description,
    this.lat,
    this.long,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [];
}

class StoryImagePathEvent extends StoryEvent {
  final String? imagePath;

  StoryImagePathEvent({required this.imagePath});

  @override
  List<Object?> get props => [];
}

class StoryImageFileEvent extends StoryEvent {
  final XFile? imageFile;

  StoryImageFileEvent({required this.imageFile});

  @override
  List<Object?> get props => [];
}

class StorySetImageEvent extends StoryEvent {
  final String? imagePath;
  final XFile? imageFile;

  StorySetImageEvent({required this.imagePath, required this.imageFile});

  @override
  List<Object?> get props => [];
}

class StorySetPageItemsEvent extends StoryEvent {
  @override
  List<Object?> get props => [];
}
