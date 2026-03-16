import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/utils/date_time_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ItineraryExperienceCard extends StatelessWidget {
  final Experience experience;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onViewExperienceTap;

  final bool isVisited;

  const ItineraryExperienceCard({
    Key? key,
    required this.experience,
    this.isSelected = false,
    this.isVisited = false,
    required this.onTap,
    this.onViewExperienceTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF34A853), width: 2)
              : Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Hero(
                  tag: 'experience-img-${experience.experienceId}',
                  child: ColorFiltered(
                    colorFilter: isVisited
                        ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                        : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                    child: CachedNetworkImage(
                      imageUrl: experience.imageUrls.isNotEmpty
                          ? experience.imageUrls.first
                          : '',
                      width: 100,
                      height: 100, // Minimal height to ensure consistency
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) =>
                          Container(color: Colors.grey[200]),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        experience.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isVisited ? Colors.grey : const Color(0xFF1D1D1F),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        experience.destinationName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6E6E73),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _buildStayTimeBadge(experience.visitStartTime, experience.visitEndTime),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: onViewExperienceTap,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF34A853),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'View Experience',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItineraryMealSleepBlock extends StatelessWidget {
  final Experience? experience;
  final bool isMeal;
  final String? customTitle;
  final String? customName;
  final String? customDescription;

  const ItineraryMealSleepBlock({
    Key? key,
    this.experience,
    required this.isMeal,
    this.customTitle,
    this.customName,
    this.customDescription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = experience?.title ?? customTitle ?? '';
    final name = experience?.name ?? customName ?? '';
    final description = experience?.description ?? customDescription ?? '';

    // Determine emoji based on name/title
    String emoji = isMeal ? '🍽️' : '😴';
    if (isMeal) {
      if (name.toLowerCase().contains('breakfast') ||
          title.toLowerCase().contains('breakfast'))
        emoji = '🍳';
      else if (name.toLowerCase().contains('lunch') ||
          title.toLowerCase().contains('lunch')) emoji = '🥪';
    }

    // Check if it's an advertisement (dummy experience with a website URL)
    final hasAd = experience != null &&
        experience!.experienceId == -1 &&
        experience!.website.isNotEmpty;

    if (hasAd) {
      final bgColor = const Color(0xFFFFFBF0);
      final brColor = const Color(0xFFF5E6C8);
      return Column(
        children: [
          Container(
            height: 12,
            width: 1,
            color: brColor,
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: brColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (experience!.imageUrls.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: experience!.imageUrls.first,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) =>
                            Container(color: Colors.grey[200]),
                      ),
                    )
                  else
                    Container(
                      width: 100,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8E8E8),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child:
                            Text(emoji, style: const TextStyle(fontSize: 30)),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                    Text(
                                      isMeal
                                          ? (title.contains('Breakfast')
                                              ? 'Breakfast'
                                              : (title.contains('Lunch')
                                                  ? 'Lunch'
                                                  : 'Dinner'))
                                          : 'Sleep',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[600],
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 4),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1D1D1F),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
                                final uri = Uri.parse(experience!.website);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF34A853),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'View Location',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 12,
            width: 1,
            color: brColor,
          ),
        ],
      );
    }

    // Colors for non-ad cards
    final baseBgColor = const Color(0xFFFFFBF0);
    final baseBorderColor = const Color(0xFFF5E6C8);
    final baseTextColor = const Color(0xFF7D5A2B);

    // Check if it's a simple status item (Sleep, Breakfast, Lunch, Dinner)
    final compactNames = ['sleep', 'breakfast', 'lunch', 'dinner'];
    if (compactNames.contains(name.trim().toLowerCase())) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 12,
                width: 1,
                color: baseBorderColor,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: baseBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: baseBorderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: baseTextColor,
                          ),
                        ),
                        if (description.isNotEmpty)
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 10,
                              color: baseTextColor.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 12,
                width: 1,
                color: baseBorderColor,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 12,
          width: 1,
          color: baseBorderColor,
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: baseBgColor,
            border: Border.all(color: baseBorderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        isMeal ? 'Meal: $name' : name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: baseTextColor,
                        ),
                      ),
                    if (description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 11,
                            color: baseTextColor.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 12,
          width: 1,
          color: baseBorderColor,
        ),
      ],
    );

  }
}

class ItineraryTransitBlock extends StatelessWidget {
  final String transportType; // 'car' or 'walking'
  final String? duration;

  const ItineraryTransitBlock({
    Key? key,
    this.transportType = 'car',
    this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 12,
              width: 1,
              color: const Color(0xFFDADCE0),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDADCE0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    transportType == 'car' ? '🚗' : '🚶',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Transit',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5F6368),
                    ),
                  ),
                  if (duration != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 12,
                      color: const Color(0xFFDADCE0),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      duration!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF5F6368),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              height: 12,
              width: 1,
              color: const Color(0xFFDADCE0),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildStayTimeBadge(DateTime start, DateTime end, {bool compact = false}) {
  final duration = end.difference(start);
  final durationStr = DateTimeUtils.formatDuration(duration);

  return Container(
    padding: EdgeInsets.zero,
    decoration: const BoxDecoration(),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.access_time,
          size: compact ? 10 : 12,
          color: const Color(0xFF5F6368),
        ),
        SizedBox(width: compact ? 2 : 4),
        Text(
          durationStr,
          style: TextStyle(
            fontSize: compact ? 9 : 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF5F6368),
          ),
        ),
      ],
    ),
  );
}
