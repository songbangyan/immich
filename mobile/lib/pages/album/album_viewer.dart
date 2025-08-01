import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/extensions/build_context_extensions.dart';
import 'package:immich_mobile/models/albums/asset_selection_page_result.model.dart';
import 'package:immich_mobile/pages/album/album_control_button.dart';
import 'package:immich_mobile/pages/album/album_date_range.dart';
import 'package:immich_mobile/pages/album/album_description.dart';
import 'package:immich_mobile/pages/album/album_shared_user_icons.dart';
import 'package:immich_mobile/pages/album/album_title.dart';
import 'package:immich_mobile/providers/album/album.provider.dart';
import 'package:immich_mobile/providers/album/current_album.provider.dart';
import 'package:immich_mobile/providers/asset_viewer/current_asset.provider.dart';
import 'package:immich_mobile/providers/timeline.provider.dart';
import 'package:immich_mobile/utils/immich_loading_overlay.dart';
import 'package:immich_mobile/providers/multiselect.provider.dart';
import 'package:immich_mobile/providers/auth.provider.dart';
import 'package:immich_mobile/widgets/album/album_viewer_appbar.dart';
import 'package:immich_mobile/routing/router.dart';
import 'package:immich_mobile/entities/asset.entity.dart';
import 'package:immich_mobile/widgets/asset_grid/multiselect_grid.dart';
import 'package:immich_mobile/widgets/common/immich_toast.dart';

class AlbumViewer extends HookConsumerWidget {
  const AlbumViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final album = ref.watch(currentAlbumProvider);
    if (album == null) {
      return const SizedBox();
    }

    final titleFocusNode = useFocusNode();
    final descriptionFocusNode = useFocusNode();
    final userId = ref.watch(authProvider).userId;
    final isMultiselecting = ref.watch(multiselectProvider);
    final isProcessing = useProcessingOverlay();
    final isOwner = ref.watch(
      currentAlbumProvider.select((album) {
        return album?.ownerId == userId;
      }),
    );

    Future<bool> onRemoveFromAlbumPressed(Iterable<Asset> assets) async {
      final bool isSuccess = await ref.read(albumProvider.notifier).removeAsset(album, assets);

      if (!isSuccess) {
        ImmichToast.show(
          context: context,
          msg: "album_viewer_appbar_share_err_remove".tr(),
          toastType: ToastType.error,
          gravity: ToastGravity.BOTTOM,
        );
      }
      return isSuccess;
    }

    /// Find out if the assets in album exist on the device
    /// If they exist, add to selected asset state to show they are already selected.
    void onAddPhotosPressed() async {
      AssetSelectionPageResult? returnPayload = await context.pushRoute<AssetSelectionPageResult?>(
        AlbumAssetSelectionRoute(existingAssets: album.assets, canDeselect: false),
      );

      if (returnPayload != null && returnPayload.selectedAssets.isNotEmpty) {
        // Check if there is new assets add
        isProcessing.value = true;

        await ref.watch(albumProvider.notifier).addAssets(album, returnPayload.selectedAssets);

        isProcessing.value = false;
      }
    }

    void onAddUsersPressed() async {
      List<String>? sharedUserIds = await context.pushRoute<List<String>?>(
        AlbumAdditionalSharedUserSelectionRoute(album: album),
      );

      if (sharedUserIds != null) {
        isProcessing.value = true;

        await ref.watch(albumProvider.notifier).addUsers(album, sharedUserIds);

        isProcessing.value = false;
      }
    }

    onActivitiesPressed() {
      if (album.remoteId != null) {
        ref.read(currentAssetProvider.notifier).set(null);
        context.pushRoute(const ActivitiesRoute());
      }
    }

    return Stack(
      children: [
        MultiselectGrid(
          key: const ValueKey("albumViewerMultiselectGrid"),
          renderListProvider: albumTimelineProvider(album.id),
          topWidget: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.primaryColor.withValues(alpha: 0.06),
                  context.primaryColor.withValues(alpha: 0.04),
                  Colors.indigo.withValues(alpha: 0.02),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const AlbumDateRange(),
                AlbumTitle(key: const ValueKey("albumTitle"), titleFocusNode: titleFocusNode),
                AlbumDescription(key: const ValueKey("albumDescription"), descriptionFocusNode: descriptionFocusNode),
                const AlbumSharedUserIcons(),
                if (album.isRemote)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: AlbumControlButton(
                      key: const ValueKey("albumControlButton"),
                      onAddPhotosPressed: onAddPhotosPressed,
                      onAddUsersPressed: isOwner ? onAddUsersPressed : null,
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          onRemoveFromAlbum: onRemoveFromAlbumPressed,
          editEnabled: album.ownerId == userId,
        ),
        AnimatedPositioned(
          key: const ValueKey("albumViewerAppbarPositioned"),
          duration: const Duration(milliseconds: 300),
          top: isMultiselecting ? -(kToolbarHeight + context.padding.top) : 0,
          left: 0,
          right: 0,
          child: AlbumViewerAppbar(
            key: const ValueKey("albumViewerAppbar"),
            titleFocusNode: titleFocusNode,
            descriptionFocusNode: descriptionFocusNode,
            userId: userId,
            onAddPhotos: onAddPhotosPressed,
            onAddUsers: onAddUsersPressed,
            onActivities: onActivitiesPressed,
          ),
        ),
      ],
    );
  }
}
