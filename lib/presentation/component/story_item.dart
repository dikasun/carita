import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lottie/lottie.dart';

import '../../data/models/story_response.dart';

class StoryItem extends StatefulWidget {
  final ListStory story;
  final Function(String storyId) toDetailScreen;

  const StoryItem({
    Key? key,
    required this.story,
    required this.toDetailScreen,
  }) : super(key: key);

  @override
  State<StoryItem> createState() => _StoryItemState();
}

class _StoryItemState extends State<StoryItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: InkWell(
        onTap: () => widget.toDetailScreen(widget.story.id),
        borderRadius: BorderRadius.circular(8.0),
        splashColor: Colors.white24,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  cacheKey: widget.story.id,
                  imageUrl: widget.story.photoUrl,
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
                      widget.story.id,
                      stalePeriod: const Duration(
                        minutes: 10,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 12.0,
              ),
              Text(
                widget.story.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
