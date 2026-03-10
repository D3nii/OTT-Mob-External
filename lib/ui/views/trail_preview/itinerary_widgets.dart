import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:onetwotrail/repositories/models/experience.dart';

class ItineraryExperienceCard extends StatelessWidget {
  final Experience experience;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onViewExperienceTap;

  const ItineraryExperienceCard({
    Key? key,
    required this.experience,
    this.isSelected = false,
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        experience.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D1D1F),
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

    final emoji = isMeal
        ? (title.toLowerCase().contains('breakfast')
            ? '🍳'
            : (title.toLowerCase().contains('lunch') ? '🥪' : '🍽️'))
        : '😴';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        border: Border.all(color: const Color(0xFFF5E6C8)),
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
                  isMeal ? 'Meal: $name' : 'Sleep: $name',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7D5A2B),
                  ),
                ),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7D5A2B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ItineraryTransitBlock extends StatelessWidget {
  final String transportType; // 'car' or 'walking'

  const ItineraryTransitBlock({
    Key? key,
    this.transportType = 'car',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 4), // Reduced padding so vertical line looks continuous
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 16,
              width: 1.5,
              color: Colors.grey[300],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    transportType == 'car'
                        ? Icons.directions_car_rounded
                        : Icons.directions_walk_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Transit',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 16,
              width: 1.5,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }
}
