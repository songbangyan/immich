import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/extensions/build_context_extensions.dart';
import 'package:immich_mobile/providers/activity_statistics.provider.dart';
import 'package:immich_mobile/providers/album/current_album.provider.dart';
import 'package:immich_mobile/entities/asset.entity.dart';
import 'package:immich_mobile/providers/asset.provider.dart';
import 'package:immich_mobile/providers/routes.provider.dart';
import 'package:immich_mobile/providers/cast.provider.dart';
import 'package:immich_mobile/providers/tab.provider.dart';
import 'package:immich_mobile/providers/websocket.provider.dart';
import 'package:immich_mobile/widgets/asset_viewer/cast_dialog.dart';
import 'package:immich_mobile/widgets/asset_viewer/motion_photo_button.dart';
import 'package:immich_mobile/providers/asset_viewer/current_asset.provider.dart';

class TopControlAppBar extends HookConsumerWidget {
  const TopControlAppBar({
    super.key,
    required this.asset,
    required this.onMoreInfoPressed,
    required this.onDownloadPressed,
    required this.onLocatePressed,
    required this.onAddToAlbumPressed,
    required this.onRestorePressed,
    required this.onFavorite,
    required this.onUploadPressed,
    required this.isOwner,
    required this.onActivitiesPressed,
    required this.isPartner,
  });

  final Asset asset;
  final Function onMoreInfoPressed;
  final VoidCallback? onUploadPressed;
  final VoidCallback? onDownloadPressed;
  final VoidCallback onLocatePressed;
  final VoidCallback onAddToAlbumPressed;
  final VoidCallback onRestorePressed;
  final VoidCallback onActivitiesPressed;
  final Function(Asset) onFavorite;
  final bool isOwner;
  final bool isPartner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInLockedView = ref.watch(inLockedViewProvider);
    const double iconSize = 22.0;
    final a = ref.watch(assetWatcher(asset)).value ?? asset;
    final album = ref.watch(currentAlbumProvider);
    final isCasting = ref.watch(castProvider.select((c) => c.isCasting));
    final websocketConnected = ref.watch(websocketProvider.select((c) => c.isConnected));

    final comments = album != null && album.remoteId != null && asset.remoteId != null
        ? ref.watch(activityStatisticsProvider(album.remoteId!, asset.remoteId))
        : 0;

    Widget buildFavoriteButton(a) {
      return IconButton(
        onPressed: () => onFavorite(a),
        icon: Icon(a.isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.grey[200]),
      );
    }

    Widget buildLocateButton() {
      return IconButton(
        onPressed: () {
          onLocatePressed();
        },
        icon: Icon(Icons.image_search, color: Colors.grey[200]),
      );
    }

    Widget buildMoreInfoButton() {
      return IconButton(
        onPressed: () {
          onMoreInfoPressed();
        },
        icon: Icon(Icons.info_outline_rounded, color: Colors.grey[200]),
      );
    }

    Widget buildDownloadButton() {
      return IconButton(
        onPressed: onDownloadPressed,
        icon: Icon(Icons.cloud_download_outlined, color: Colors.grey[200]),
      );
    }

    Widget buildAddToAlbumButton() {
      return IconButton(
        onPressed: () {
          onAddToAlbumPressed();
        },
        icon: Icon(Icons.add, color: Colors.grey[200]),
      );
    }

    Widget buildRestoreButton() {
      return IconButton(
        onPressed: () {
          onRestorePressed();
        },
        icon: Icon(Icons.history_rounded, color: Colors.grey[200]),
      );
    }

    Widget buildActivitiesButton() {
      return IconButton(
        onPressed: () {
          onActivitiesPressed();
        },
        icon: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.mode_comment_outlined, color: Colors.grey[200]),
            if (comments != 0)
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  comments.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[200]),
                ),
              ),
          ],
        ),
      );
    }

    Widget buildUploadButton() {
      return IconButton(
        onPressed: onUploadPressed,
        icon: Icon(Icons.backup_outlined, color: Colors.grey[200]),
      );
    }

    Widget buildBackButton() {
      return IconButton(
        onPressed: () {
          context.maybePop();
        },
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.0, color: Colors.grey[200]),
      );
    }

    Widget buildCastButton() {
      return IconButton(
        onPressed: () {
          showDialog(context: context, builder: (context) => const CastDialog());
        },
        icon: Icon(
          isCasting ? Icons.cast_connected_rounded : Icons.cast_rounded,
          size: 20.0,
          color: isCasting ? context.primaryColor : Colors.grey[200],
        ),
      );
    }

    bool isInHomePage = ref.read(tabProvider.notifier).state == TabEnum.home;
    bool? isInTrash = ref.read(currentAssetProvider)?.isTrashed;

    return AppBar(
      foregroundColor: Colors.grey[100],
      backgroundColor: Colors.transparent,
      leading: buildBackButton(),
      actionsIconTheme: const IconThemeData(size: iconSize),
      shape: const Border(),
      actions: [
        if (asset.isRemote && isOwner) buildFavoriteButton(a),
        if (isOwner && !isInHomePage && !(isInTrash ?? false) && !isInLockedView) buildLocateButton(),
        if (asset.livePhotoVideoId != null) const MotionPhotoButton(),
        if (asset.isLocal && !asset.isRemote) buildUploadButton(),
        if (asset.isRemote && !asset.isLocal && isOwner) buildDownloadButton(),
        if (asset.isRemote && (isOwner || isPartner) && !asset.isTrashed && !isInLockedView) buildAddToAlbumButton(),
        if (isCasting || (asset.isRemote && websocketConnected)) buildCastButton(),
        if (asset.isTrashed) buildRestoreButton(),
        if (album != null && album.shared && !isInLockedView) buildActivitiesButton(),
        buildMoreInfoButton(),
      ],
    );
  }
}
