import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:moekey/networks/apis.dart';
import 'package:moekey/pages/home/home_page_state.dart';
import 'package:moekey/state/server.dart';
import 'package:moekey/state/themes.dart';
import 'package:moekey/widgets/context_menu.dart';
import 'package:moekey/widgets/login/servers_select.dart';

import '../../main.dart';
import '../../widgets/blur_widget.dart';
import '../../widgets/hover_builder.dart';
import '../../widgets/mk_image.dart';
import '../../widgets/note_create_dialog/note_create_dialog.dart';
import '../user_widgets/widgets_list/view.dart';

class HomePage extends HookConsumerWidget {
  HomePage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void _openDrawer() {
    _scaffoldKey.currentState!.openDrawer();
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState!.openEndDrawer();
  }

  void _closeDrawer() {
    _scaffoldKey.currentState!.closeDrawer();
  }

  void _closeEndDrawer() {
    _scaffoldKey.currentState!.closeEndDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var themes = ref.watch(themeColorsProvider);
    var router = ref.watch(routerDelegateProvider);
    var info = ref.watch(serverInfoStateProvider.future);
    var meta = ref.watch(apiMetaProvider);
    var currentId = useState(router.currentConfiguration?.path);
    func() {
      currentId.value = router.currentConfiguration?.path;
    }

    var isShowBottomNav = [
      "timeline",
      "notifications",
      "clips",
      "drive",
      "explore",
      "announcements",
      "search"
    ].contains(currentId.value);

    useEffect(() {
      func();
      router.addListener(func);
      return () {
        router.removeListener(func);
      };
    }, const []);
    var media = MediaQuery.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      var btnStyle =
          ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) {
        return themes.panelColor.withOpacity(0.5);
      }));
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: themes.bgColor,
        drawer: constraints.maxWidth < 500
            ? NavBar(
                width: 250,
                onSelect: _closeDrawer,
              )
            : null,
        endDrawer: constraints.maxWidth < 500
            ? Container(
                color: themes.panelColor,
                child: WidgetsListPage(),
              )
            : null,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Row(
                children: [
                  if (constraints.maxWidth >= 500)
                    NavBar(
                      width: constraints.maxWidth < 1280 ? 80 : 250,
                    ),
                  Expanded(
                    child: MediaQuery(
                      data: media.copyWith(
                          padding: media.padding.copyWith(
                              bottom: media.padding.bottom +
                                  (constraints.maxWidth > 500 ||
                                          !isShowBottomNav
                                      ? 0
                                      : 100))),
                      child: Router(
                        routerDelegate: router,
                        backButtonDispatcher: RootBackButtonDispatcher(),
                      ),
                    ),
                  ),
                  if (constraints.maxWidth >= 1190) WidgetsListPage()
                ],
              ),
              if (constraints.maxWidth < 500)
                AnimatedPositioned(
                  bottom: isShowBottomNav ? 0 : -86,
                  left: 0,
                  duration: const Duration(milliseconds: 250),
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: 86,
                    child: BlurWidget(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: _openDrawer,
                            icon: const Icon(TablerIcons.menu_2),
                            padding: const EdgeInsets.all(20),
                            color: themes.fgColor,
                            style: btnStyle,
                          ),
                          IconButton(
                            onPressed: () {
                              var logic =
                                  ref.read(homePageStateProvider.notifier);
                              logic.changePage("timeline");
                            },
                            icon: const Icon(TablerIcons.home),
                            padding: const EdgeInsets.all(20),
                            color: themes.fgColor,
                            style: btnStyle,
                          ),
                          IconButton(
                            onPressed: () {
                              var logic =
                                  ref.read(homePageStateProvider.notifier);
                              logic.changePage("notifications");
                            },
                            icon: const Icon(TablerIcons.bell),
                            padding: const EdgeInsets.all(20),
                            color: themes.fgColor,
                            style: btnStyle,
                          ),
                          IconButton(
                            onPressed: _openEndDrawer,
                            icon: const Icon(TablerIcons.apps),
                            padding: const EdgeInsets.all(20),
                            color: themes.fgColor,
                            style: btnStyle,
                          ),
                          IconButton(
                            onPressed: () {
                              globalNav.currentState
                                  ?.push(NoteCreateDialog.getRouter());
                            },
                            icon: const Icon(TablerIcons.pencil),
                            padding: const EdgeInsets.all(20),
                            color: themes.fgColor,
                            style: btnStyle,
                          )
                        ],
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      );
    });
  }
}

class NavBar extends HookConsumerWidget {
  const NavBar({
    super.key,
    required this.width,
    this.onSelect,
  });
  final void Function()? onSelect;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var themes = ref.watch(themeColorsProvider);
    var state = ref.watch(homePageStateProvider);
    var currentId = useState(state.navItemList[0]["id"]);
    var router = ref.watch(routerDelegateProvider);
    func() {
      currentId.value = router.currentConfiguration?.path;
    }

    useEffect(() {
      func();
      router.addListener(func);
      return () {
        router.removeListener(func);
      };
    }, const []);
    return AnimatedContainer(
      width: width,
      color: themes.navBgColor,
      height: double.infinity,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const ServerIconAndBanner(),
            Expanded(child: SingleChildScrollView(
              child: Builder(builder: (context) {
                var list = <Widget>[];
                for (var element in state.navItemList) {
                  if (element["line"] == null) {
                    list.add(NavbarItem(
                      icon: element["icon"],
                      label: element["label"],
                      id: element["id"],
                      currentId: currentId.value,
                      onSelect: () {
                        currentId.value = element["id"];
                        if (onSelect != null) {
                          onSelect!();
                        }
                      },
                    ));
                  } else {
                    list.add(Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                      child: SizedBox(
                        width: double.infinity,
                        height: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: themes.dividerColor),
                        ),
                      ),
                    ));
                  }
                }
                return SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: list,
                  ),
                );
              }),
            )),
            const SizedBox(height: 20),
            const CreateBottom(),
            const SizedBox(height: 20),
            const UserAvatarButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ServerIconAndBanner extends ConsumerWidget {
  const ServerIconAndBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var mediaPadding = MediaQuery.paddingOf(context);
    var meta = ref.watch(apiMetaProvider.future);
    return LayoutBuilder(
      builder: (context, constraints) {
        return FutureBuilder(
          future: meta,
          builder: (context, snapshot) {
            var metaData = snapshot.data;
            var icon = Builder(builder: (BuildContext context) {
              if (metaData?["iconUrl"] != null) {
                return MkImage(metaData!["iconUrl"], width: 30, height: 30);
              } else {
                return Image.asset(
                  "assets/favicon.ico",
                  width: 30,
                  height: 30,
                );
              }
            });

            var extend = constraints.maxWidth >= 250;
            if (extend) {
              return SizedBox(
                  width: double.infinity,
                  height: 82 + mediaPadding.top,
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black, Colors.transparent],
                              stops: [0, 0.9])
                          .createShader(
                              Rect.fromLTRB(0, 0, rect.width, rect.height));
                    },
                    blendMode: BlendMode.dstIn,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        MkImage(
                          metaData?["bannerUrl"] ?? "",
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        SizedBox(
                          width: 38,
                          height: 38,
                          child: icon,
                        )
                      ],
                    ),
                  ));
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: icon,
            );
          },
        );
      },
    );
  }
}

class UserAvatarButton extends ConsumerWidget {
  const UserAvatarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var user = ref.watch(currentLoginUserProvider);
    var userData = user.valueOrNull?.userInfo;
    return LayoutBuilder(builder: (context, constraints) {
      var extend = constraints.maxWidth >= 250;
      return ContextMenuBuilder(
        menu: ContextMenuCard(
          menuListBuilder: () async {
            var list = await ref.read(loginUserListProvider.future);
            var user = await ref.read(currentLoginUserProvider.future);
            return [
              ContextMenuItem(
                divider: true,
                widget: (context, large, isHover) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: large ? 16 : 4, horizontal: large ? 16 : 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: MkImage(user?.userInfo["avatarUrl"],
                              shape: BoxShape.circle),
                        ),
                        SizedBox(width: large ? 8 : 4),
                        Expanded(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (user?.userInfo["name"] != null)
                              Text(user?.userInfo["name"] ?? "")
                            else
                              Text("@${user?.userInfo["username"] ?? ""}"),
                          ],
                        ))
                      ],
                    ),
                  );
                },
              ),
              for (var item in list.values)
                if (item.id != user?.id)
                  ContextMenuItem(
                    widget: (context, large, isHover) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: MkImage(item.userInfo["avatarUrl"],
                                  shape: BoxShape.circle),
                            ),
                            SizedBox(width: 4),
                            Expanded(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.userInfo["name"] != null)
                                  Text(item.userInfo["name"] ?? "")
                                else
                                  Text("@${item.userInfo["username"] ?? ""}"),
                              ],
                            ))
                          ],
                        ),
                      );
                    },
                    onTap: () {
                      ref
                          .read(currentLoginUserProvider.notifier)
                          .setLoginUser(item.id);
                      return false;
                    },
                  ),
              ContextMenuItem(
                icon: TablerIcons.plus,
                label: "添加账号",
                onTap: () {
                  Timer(Duration(milliseconds: 150), () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Material(
                              color: Colors.transparent,
                              child: Center(
                                child: SizedBox(
                                  width: 450,
                                  height: 600,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: const ServersSelectCard(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        useRootNavigator: true);
                  });
                  return false;
                },
              ),
              ContextMenuItem(icon: TablerIcons.users, label: "管理账号"),
            ];
          },
        ),
        mode: const [ContextMenuMode.onTap, ContextMenuMode.onSecondaryTap],
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            child: Tooltip(
              message: extend ? "" : "账户：@${userData?["username"] ?? ""}",
              child: Row(
                mainAxisAlignment:
                    extend ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  userData?["avatarUrl"] != null
                      ? MkImage(
                          userData?["avatarUrl"],
                          width: extend ? 32 : 38,
                          height: extend ? 32 : 38,
                          fit: BoxFit.cover,
                          shape: BoxShape.circle,
                        )
                      : SizedBox(
                          width: extend ? 32 : 38,
                          height: extend ? 32 : 38,
                        ),
                  if (extend) const SizedBox(width: 8),
                  if (extend)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (userData?["name"] != null)
                          Text(userData?["name"] ?? ""),
                        Text("@${userData?["username"] ?? ""}"),
                      ],
                    )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class NavbarItem extends ConsumerWidget {
  final IconData icon;
  final String label;
  final String id;
  final String currentId;
  final void Function()? onSelect;
  const NavbarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.id,
    this.onSelect,
    required this.currentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var themes = ref.watch(themeColorsProvider);
    var isActive = currentId == id;
    return LayoutBuilder(
      builder: (context, constraints) {
        var extend = constraints.maxWidth >= 250;
        if (extend) {
          return HoverBuilder(builder: (context, isHover) {
            var textColor =
                isHover || isActive ? themes.accentColor : themes.fgColor;
            return GestureDetector(
              onTap: () {
                var logic = ref.read(homePageStateProvider.notifier);
                logic.changePage(id);
                if (onSelect != null) {
                  onSelect!();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                  color: isHover || isActive
                      ? themes.accentedBgColor
                      : Colors.transparent,
                ),
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                margin: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                    ),
                    Icon(icon, size: 16, color: textColor),
                    const SizedBox(
                      width: 16,
                    ),
                    Text(
                      label,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: textColor),
                    ),
                  ],
                ),
              ),
            );
          });
        }
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (onSelect != null) {
                onSelect!();
              }
              var logic = ref.read(homePageStateProvider.notifier);
              logic.changePage(id);
            },
            borderRadius: const BorderRadius.all(Radius.circular(100)),
            hoverColor: themes.accentedBgColor,
            splashColor: themes.accentedBgColor,
            child: HoverBuilder(builder: (context, isHover) {
              return Tooltip(
                message: label,
                child: Container(
                  decoration: BoxDecoration(
                      color: isActive
                          ? themes.accentedBgColor
                          : Colors.transparent,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(100))),
                  padding: const EdgeInsets.all(18),
                  child: Icon(icon,
                      size: 18,
                      color: isHover || isActive
                          ? themes.accentColor
                          : themes.fgColor),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class CreateBottom extends ConsumerWidget {
  const CreateBottom({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var themes = ref.watch(themeColorsProvider);

    onPressed() {
      globalNav.currentState?.push(NoteCreateDialog.getRouter());
    }

    return LayoutBuilder(builder: (context, constraints) {
      var extend = constraints.maxWidth >= 250;
      if (extend) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
          child: TextButton(
            onPressed: onPressed,
            style: ButtonStyle(
              splashFactory: InkSparkle.splashFactory,
              animationDuration: Duration.zero,
              shadowColor: MaterialStateProperty.all(Colors.transparent),
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.hovered)) {
                  return themes.buttonGradateBColor;
                }
                return themes.buttonGradateAColor;
              }),
              foregroundColor: MaterialStateProperty.resolveWith((states) {
                return themes.fgOnAccentColor;
              }),
            ),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                children: [
                  Icon(TablerIcons.pencil, size: 16),
                  SizedBox(
                    width: 16,
                  ),
                  Text("帖子"),
                ],
              ),
            ),
          ),
        );
      }
      return IconButton(
        onPressed: onPressed,
        icon: const Icon(TablerIcons.pencil),
        padding: const EdgeInsets.all(18),
        tooltip: "帖子",
        isSelected: false,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.hovered)) {
                return themes.buttonGradateBColor;
              }
              return themes.buttonGradateAColor;
            }),
            foregroundColor: MaterialStateProperty.resolveWith((states) {
              return themes.fgOnAccentColor;
            }),
            iconSize: MaterialStateProperty.all(20)),
      );
    });
  }
}
