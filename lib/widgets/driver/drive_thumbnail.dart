import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:moekey/status/themes.dart';
import 'package:moekey/widgets/context_menu.dart';
import 'package:moekey/widgets/hover_builder.dart';
import 'package:moekey/widgets/mk_button.dart';
import 'package:moekey/widgets/mk_text_input_dialog.dart';
import 'package:moekey/widgets/note_create_dialog/note_create_dialog.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../apis/models/drive.dart';
import '../../generated/l10n.dart';
import '../mk_dialog.dart';
import '../mk_image.dart';
import 'drive.dart';

class DriveImageThumbnail extends HookConsumerWidget {
  const DriveImageThumbnail({
    super.key,
    this.isSelect = false,
    this.onRemove,
    required this.data,
  });

  final DriveModel data;
  final bool isSelect;
  final void Function()? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var themes = ref.watch(themeColorsProvider);
    return ContextMenuBuilder(
        mode: const [
          ContextMenuMode.onSecondaryTap,
          ContextMenuMode.onLongPress
        ],
        menu: ContextMenuCard(
          initialChildSize: data is DriverFolderModel ? 0.3 : 0.6,
          maxChildSize: data is DriverFolderModel ? 0.3 : 0.6,
          minChildSize: data is DriverFolderModel ? 0.3 : 0.6,
          width: 200,
          menuListBuilder: () {
            return [
              if (data is DriverFolderModel) ...[
                ContextMenuItem(
                  label: S.current.rename,
                  icon: TablerIcons.forms,
                  divider: true,
                  onTap: () {
                    Timer(
                      const Duration(milliseconds: 150),
                      () {
                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return getRenameDialog(themes);
                          },
                        );
                      },
                    );

                    return false;
                  },
                ),
                ContextMenuItem(
                    label: S.current.delete,
                    icon: TablerIcons.trash,
                    danger: true,
                    onTap: () {
                      Timer(
                        const Duration(milliseconds: 150),
                        () {
                          if (!context.mounted) return;
                          showDialog(
                            context: context,
                            builder: (context) {
                              return getDeleteDialog(themes);
                            },
                          );
                        },
                      );

                      return false;
                    })
              ] else if (data is DriveFileModel) ...[
                ContextMenuItem(
                  label: S.current.rename,
                  icon: TablerIcons.forms,
                  onTap: () {
                    Timer(
                      const Duration(milliseconds: 150),
                      () {
                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return getRenameDialog(themes);
                          },
                        );
                      },
                    );

                    return false;
                  },
                ),
                if ((data as DriveFileModel).isSensitive)
                  ContextMenuItem(
                      label: S.current.cancelSensitive,
                      icon: TablerIcons.eye,
                      onTap: () {
                        ref
                            .read(driverUploaderProvider.notifier)
                            .updateFile(fileId: data.id, isSensitive: false);
                        return false;
                      })
                else
                  ContextMenuItem(
                    label: S.current.markAsSensitive,
                    icon: TablerIcons.eye_exclamation,
                    onTap: () {
                      ref
                          .read(driverUploaderProvider.notifier)
                          .updateFile(fileId: data.id, isSensitive: true);
                      return false;
                    },
                  ),
                ContextMenuItem(
                  label: S.current.addTitle,
                  icon: TablerIcons.text_caption,
                  divider: true,
                  onTap: () {
                    Timer(
                      const Duration(milliseconds: 150),
                      () async {
                        if (!context.mounted) return;
                        var text = await showDialog(
                          context: context,
                          builder: (context) {
                            return getCommentDialog(themes);
                          },
                        );
                        ref
                            .read(driverUploaderProvider.notifier)
                            .updateFile(fileId: data.id, comment: text);
                      },
                    );

                    return false;
                  },
                ),
                ContextMenuItem(
                  label: S.current.createNoteFormFile,
                  icon: TablerIcons.pencil,
                  onTap: () async {
                    Timer(const Duration(milliseconds: 150), () {
                      NoteCreateDialog.open(context: context, files: [
                        data as DriveFileModel,
                      ]);
                    });

                    return false;
                  },
                ),
                ContextMenuItem(
                  label: S.current.copyLink,
                  icon: TablerIcons.link,
                  onTap: () {
                    Clipboard.setData(ClipboardData(
                      text: (data as DriveFileModel).url,
                    ));
                    return false;
                  },
                ),
                ContextMenuItem(
                    label: S.current.download,
                    icon: TablerIcons.download,
                    divider: true,
                    onTap: () {
                      launchUrl(Uri.parse(
                        (data as DriveFileModel).url,
                      ));
                      return false;
                    }),
                ContextMenuItem(
                  label: S.current.delete,
                  icon: TablerIcons.trash,
                  danger: true,
                  onTap: () {
                    Timer(
                      const Duration(milliseconds: 150),
                      () {
                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return getDeleteDialog(themes);
                          },
                        );
                      },
                    );

                    return false;
                  },
                )
              ]
            ];
          },
        ),
        child: GestureDetector(
          onTap: data is DriverFolderModel
              ? () {
                  ref
                      .read(drivePathProvider.notifier)
                      .push(name: data.name, id: data.id);
                }
              : null,
          behavior: HitTestBehavior.opaque,
          child: HoverBuilder(
            builder: (context, isHover) {
              Color? bgColor =
                  isHover ? themes.buttonHoverBgColor : Colors.transparent;
              if (isSelect) {
                bgColor = Color.lerp(
                    themes.accentColor.withOpacity(0.6), bgColor, 0.3);
              }
              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(6),
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: [
                          if (data is DriveFileModel)
                            RepaintBoundary(
                              child: DriverFileIcon(
                                  themes: themes, data: data as DriveFileModel),
                            )
                          else
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: themes.panelColor,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(6),
                                ),
                              ),
                              child: Icon(
                                TablerIcons.folder,
                                size: 48,
                                color: themes.fgColor,
                              ),
                            )
                        ][0],
                      ),
                    ),
                    Text(
                      data.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                    )
                  ],
                ),
              );
            },
          ),
        ));
  }

  Widget getRenameDialog(ThemeColorModel themes) {
    return HookConsumer(
      builder: (context, ref, child) {
        return MkTextInputDialog(
          title: data is DriveFileModel
              ? S.current.renameFile
              : S.current.renameFolder,
          initialValue: data.name,
          onConfirm: (value) async {
            var notifier = ref.read(driverUploaderProvider.notifier);
            if (data is DriveFileModel) {
              await notifier.updateFile(fileId: data.id, name: value);
            } else {
              await notifier.updateFolders(folderId: data.id, name: value);
            }
            return true;
          },
        );
      },
    );
  }

  Widget getCommentDialog(ThemeColorModel themes) {
    return HookConsumer(
      builder: (context, ref, child) {
        return MkTextInputDialog(
          title: S.current.addTitle,
          initialValue: (data as DriveFileModel).comment,
          onConfirm: (value) async {
            await ref
                .read(driverUploaderProvider.notifier)
                .updateFile(fileId: data.id, comment: value);
            return true;
          },
        );
      },
    );
  }

  Widget getDeleteDialog(ThemeColorModel themes) {
    return HookConsumer(
      builder: (context, ref, child) {
        return MkDialog(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.center,
                child: Icon(
                  TablerIcons.alert_triangle,
                  size: 28,
                  color: themes.warnColor,
                ),
              ),
              if (data is DriveFileModel)
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    S.current.deleteFileConfirmation(data.name),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    S.current.deleteFolderConfirmation(data.name),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(
                height: 16,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MkPrimaryButton(
                    child: Text(S.current.ok),
                    onPressed: () {
                      var notifier = ref.read(driverUploaderProvider.notifier);
                      if (data is DriveFileModel) {
                        notifier.deleteFile(data.id);
                      } else {
                        notifier.deleteFolder(data.id);
                      }
                      if (onRemove != null) {
                        onRemove!();
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  MkSecondaryButton(
                    child: Text(S.current.cancel),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class DriverFileIcon extends StatelessWidget {
  const DriverFileIcon(
      {super.key,
      required this.themes,
      required this.data,
      this.fit = BoxFit.contain});

  final ThemeColorModel themes;
  final DriveFileModel data;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: themes.panelColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      child: [
        if (data.thumbnailUrl != null)
          Stack(
            children: [
              MkImage(
                data.thumbnailUrl!,
                fit: fit,
                width: double.infinity,
                height: double.infinity,
                blurHash: data.blurhash,
              ),
              if (data.isSensitive)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Text(
                    "NSFW",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
            ],
          )
        else if (extension(data.name) != "")
          Center(
            child: Text(extension(data.name).substring(1).toUpperCase(),
                style: const TextStyle(fontSize: 22)),
          )
        else
          Center(
            child: Icon(
              TablerIcons.file,
              size: 48,
              color: themes.fgColor,
            ),
          )
      ][0],
    );
  }
}
