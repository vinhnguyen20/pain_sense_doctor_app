import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';

class ClinicianHeader extends StatelessWidget {
  final String doctorName;
  final String? avatarUrl;
  final VoidCallback? onNotificationPressed;
  final ValueChanged<String>? onSearchChanged;

  const ClinicianHeader({
    super.key,
    required this.doctorName,
    this.avatarUrl,
    this.onNotificationPressed,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 542,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 19),
            decoration: BoxDecoration(
              color: AppPalette.backgroundLight,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: TextField(
              onChanged: onSearchChanged,
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: AppPalette.secondaryBlue,
              style: AppTypography.titleBig1.copyWith(
                color: AppPalette.secondaryBlue,
                height: 1.0,
              ),
              strutStyle: const StrutStyle(
                fontFamily: 'Cabin',
                fontSize: 20,
                height: 1.0,
                forceStrutHeight: true,
              ),
              decoration: InputDecoration(
                hintText: 'Search Patients...',
                hintStyle: AppTypography.titleBig1.copyWith(
                  color: AppPalette.medGray,
                  height: 1.0,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.search,
              size: 36,
              color: AppPalette.secondaryBlue,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  doctorName,
                  style: AppTypography.titleBig1.copyWith(
                    color: AppPalette.secondaryBlue,
                  ),
                ),
                const SizedBox(width: 20),
                _ProfileAvatar(avatarUrl: avatarUrl),
                const SizedBox(width: 20),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onNotificationPressed,
                  child: SizedBox(
                    width: 40,
                    height: 48,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.notifications_none_rounded,
                            size: 36,
                            color: AppPalette.secondaryBlue,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppPalette.green,
                              shape: BoxShape.circle,
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
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;

  const _ProfileAvatar({this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const _DefaultProfileIcon(),
        ),
      );
    }

    return const _DefaultProfileIcon();
  }
}

class _DefaultProfileIcon extends StatelessWidget {
  const _DefaultProfileIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppPalette.secondaryBlue, width: 3),
            ),
          ),
          Positioned(
            top: 10,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppPalette.secondaryBlue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 9,
            child: Container(
              width: 22,
              height: 12,
              decoration: const BoxDecoration(
                color: AppPalette.secondaryBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
