import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:implicitly_animated_reorderable_list_2/implicitly_animated_reorderable_list_2.dart';
import 'package:implicitly_animated_reorderable_list_2/transitions.dart';
import 'package:moekey/status/timeline.dart';
import 'package:moekey/status/themes.dart';
import 'package:moekey/utils/get_padding_note.dart';

import '../../apis/models/note.dart';
import '../../widgets/loading_weight.dart';
import '../../widgets/notes/note_card.dart';

class TimeLineListPage extends HookConsumerWidget {
  const TimeLineListPage({
    super.key,
    required this.api,
    this.nestedScroll = false,
  });

  final String api;
  final bool nestedScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var mediaPadding = MediaQuery.of(context).padding;
    var dataProvider = timelineProvider(api: api);
    var data = ref.watch(dataProvider);

    var themes = ref.watch(themeColorsProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        double padding = getPaddingForNote(constraints);
        return RefreshIndicator.adaptive(
          onRefresh: () async {
            await ref.read(dataProvider.notifier).cleanCache();
            return await ref.refresh(dataProvider.future);
          },
          edgeOffset: mediaPadding.top,
          child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: LoadingAndEmpty(
                loading: data.isLoading,
                empty: data.valueOrNull?.isEmpty ?? true,
                refresh: () async {
                  await ref.read(dataProvider.notifier).cleanCache();
                  return await ref.refresh(dataProvider.future);
                },
                child: HookConsumer(
                  builder: (context, ref, child) {
                    return CustomScrollView(
                      cacheExtent:
                          (Platform.isAndroid || Platform.isIOS) ? null : 4000,
                      // controller: scrollController,
                      slivers: [
                        if (nestedScroll)
                          SliverOverlapInjector(
                            // This is the flip side of the SliverOverlapAbsorber
                            // above.
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context),
                          ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(padding,
                              mediaPadding.top, padding, mediaPadding.bottom),
                          sliver: SliverMainAxisGroup(
                            slivers: [
                              SliverList.separated(
                                addAutomaticKeepAlives: true,
                                itemBuilder: (BuildContext context, int index) {
                                  BorderRadius borderRadius;
                                  if (index == 0) {
                                    borderRadius = const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12));
                                  } else {
                                    borderRadius =
                                        const BorderRadius.all(Radius.zero);
                                  }
                                  return NoteCard(
                                      key:
                                          ValueKey(data.valueOrNull![index].id),
                                      borderRadius: borderRadius,
                                      data: data.valueOrNull![index]);
                                  // return KeepAliveWrapper(
                                  //     child: TimelineCardComponent(
                                  //   data: data.valueOrNull![index],
                                  //   borderRadius: borderRadius,
                                  // ));
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 1,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: themes.dividerColor,
                                      ),
                                    ),
                                  );
                                },
                                itemCount: (data.valueOrNull?.length ?? 0),
                              ),
                              SliverLayoutBuilder(
                                builder: (context, constraints) {
                                  if (constraints.remainingPaintExtent > 0) {
                                    ref.read(dataProvider.notifier).load();
                                  }
                                  return const SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                        child: LoadingCircularProgress(),
                                      ),
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    );
                  },
                ),
              )),
        );
      },
    );
  }
}
