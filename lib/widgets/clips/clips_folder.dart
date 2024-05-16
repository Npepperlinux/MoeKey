import 'package:badges/badges.dart' as badges;
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:moekey/pages/clips/clips_notes.dart';
import 'package:moekey/pages/users/user_page.dart';
import 'package:moekey/router/main_router_delegate.dart';
import 'package:moekey/widgets/mfm_text/mfm_text.dart';
import 'package:moekey/widgets/mk_card.dart';
import 'package:moekey/widgets/mk_image.dart';
import 'package:moekey/widgets/mk_overflow_show.dart';

import '../../apis/models/clips.dart';
import '../../state/themes.dart';
import '../../utils/time_ago_since_date.dart';
import '../notes/note_card.dart';

class ClipsFolder extends HookConsumerWidget {
  final ClipsModel data;

  const ClipsFolder({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var textStyle = Theme.of(context).textTheme.bodyMedium;

    return DefaultTextStyle(
        style: textStyle!,
        child: MkCard(
          shadow: false,
          child: ClipsCardComponent(
            data: data,
          ),
        ));
  }
}

class ClipsCardComponent extends HookConsumerWidget {
  final ClipsModel data;

  ClipsCardComponent({super.key, required this.data});

  final ConstraintId avatar = ConstraintId('avatar');
  final ConstraintId content = ConstraintId('content');
  final double limit = 1000;
  final double height = 400;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var fontsize = DefaultTextStyle.of(context).style.fontSize!;
    var themes = ref.watch(themeColorsProvider);

    return LayoutBuilder(builder: (context, constraints) {
      var isSmall = constraints.maxWidth < 400;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            MainRouterDelegate.of(context).setNewRoutePath(
              RouterItem(
                path: "/clips/${data.id}",
                page: () => ClipsNotes(data.id),
              ),
            );
          },
          child: Container(
            color: Colors.transparent,
            child: ConstraintLayout(
              children: [
                GestureDetector(
                  onTap: () {
                    MainRouterDelegate.of(context).setNewRoutePath(
                      RouterItem(
                        path: "/user/${data.userId}",
                        page: () => UserPage(
                          userId: data.userId,
                        ),
                      ),
                    );
                  },
                  child: MkImage(
                    data.user.avatarUrl ?? "",
                    shape: BoxShape.circle,
                  ),
                ).applyConstraint(
                  top: parent.top,
                  left: parent.left,
                  size: isSmall ? 7 * (fontsize - 8) : 8 * (fontsize - 8),
                  id: avatar,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left:
                          isSmall ? 8.5 * (fontsize - 8) : 10 * (fontsize - 8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                              child: UserNameRichText(
                            data: data.user,
                            navigator: false,
                          )),
                          if (data.lastClippedAt != null)
                            Text(
                                "${formatDate(
                                  data.lastClippedAt!,
                                  [
                                    yyyy,
                                    "-",
                                    mm,
                                    "-",
                                    dd,
                                    " ",
                                    HH,
                                    ":",
                                    nn,
                                    ":",
                                    ss
                                  ],
                                )}(${timeAgoSinceDate(data.createdAt)})",
                                style: TextStyle(fontSize: fontsize * 0.9)),
                          const SizedBox(
                            width: 6,
                          ),
                          if (!data.isPublic)
                            Icon(
                              TablerIcons.lock,
                              size: fontsize,
                              color: themes.fgColor,
                            ),
                        ],
                      ),
                      Row(
                        // 两端对齐
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (data.favoritedCount != 0)
                            Row(
                              children: [
                                Text(data.favoritedCount.toString()),
                                Icon(
                                  TablerIcons.heart,
                                  size: fontsize,
                                  color: themes.fgColor,
                                )
                              ],
                            ),
                        ],
                      ),
                      MkOverflowShow(
                          content: MFMText(text: data.description ?? ""),
                          action: (isShow, p1) {
                            return const Text("查看更多");
                          },
                          limit: limit,
                          height: height)
                    ],
                  ),
                ).applyConstraint(
                  top: parent.top,
                  width: matchParent,
                  height: wrapContent,
                  id: content,
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
