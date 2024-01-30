import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:moekey/state/themes.dart';

import '../../models/drive.dart';
import '../mk_image.dart';
import '../video_player.dart';

class NoteImage extends HookConsumerWidget {
  const NoteImage(
      {super.key, this.maxHeight, required this.imageFile, this.onClick});
  final int? maxHeight;
  final DriveFileModel imageFile;
  final void Function()? onClick;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeColorsProvider);
    var isHidden = useState(false);
    useEffect(() {
      if (imageFile.isSensitive) {
        isHidden.value = true;
      }
      return null;
    }, const []);
    var isImage = false;
    var isVideo = false;
    if (imageFile.type.startsWith("image")) {
      isImage = true;
    }
    if (imageFile.type.startsWith("video")) {
      isVideo = true;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        var width = constraints.maxWidth;
        var height = maxHeight != null
            ? getHeight(imageFile.properties?["width"] ?? 16,
                imageFile.properties?["height"] ?? 9, width.toInt(), maxHeight!)
            : constraints.maxHeight;
        return ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            onTap: () {
              if (isHidden.value) {
                isHidden.value = false;
              } else {
                if (onClick != null && isImage) {
                  onClick!();
                }
              }
            },
            child: SizedBox(
              width: width,
              height: height.toDouble(),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ClipRect(
                  //   child:
                  if (imageFile.blurhash != null)
                    BlurHash(hash: imageFile.blurhash!)
                  else if (imageFile.thumbnailUrl != null)
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: 100.0,
                        sigmaY: 100.0,
                      ),
                      child: MkImage(
                        imageFile.thumbnailUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.fill,
                      ),
                    )
                  else
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: 100.0,
                        sigmaY: 100.0,
                      ),
                      child: MkImage(
                        imageFile.url,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.fill,
                      ),
                    ),
                  Container(
                    color: Colors.black.withOpacity(0.2),
                  ),
                  // ),
                  if (isHidden.value)
                    DefaultTextStyle(
                      style: DefaultTextStyle.of(context)
                          .style
                          .copyWith(color: Colors.white, fontSize: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                TablerIcons.eye_exclamation,
                                color: Colors.white,
                                size: 13,
                              ),
                              Text(imageFile.isSensitive
                                  ? "敏感内容"
                                  : isImage
                                      ? "图片"
                                      : "视频")
                            ],
                          ),
                          const Text("点击以显示")
                        ],
                      ),
                    ),
                  if (!isHidden.value)
                    if (isImage) ...[
                      if (imageFile.thumbnailUrl != null)
                        MkImage(
                          imageFile.thumbnailUrl!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        )
                      else
                        MkImage(
                          imageFile.url,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        ),
                    ] else if (isVideo)
                      VideoPlayerComponent(url: imageFile.url),
                  if (!isHidden.value)
                    Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: () {
                            isHidden.value = true;
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                            decoration: BoxDecoration(
                                color: theme.fgColor.withOpacity(0.5),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(6))),
                            child: const Icon(
                              TablerIcons.eye_off,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  num getHeight(int w, int h, int ww, int wh) {
    var a = w / h;
    var wa = ww / wh;
    if (a >= wa) {
      return (ww / w) * h;
    } else {
      return wh;
    }
  }
}
