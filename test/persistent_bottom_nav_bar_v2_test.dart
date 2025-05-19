// ignore_for_file: avoid_redundant_argument_values

import "dart:ui";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:persistent_bottom_nav_bar_v2/components/animated_icon_wrapper.dart";
import "package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart";

import "util.dart";

void main() {
  group("PersistentTabView", () {
    testWidgets("builds a DecoratedNavBar", (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
          ),
        ),
      );

      expect(find.byType(DecoratedNavBar).hitTestable(), findsOneWidget);
    });

    testWidgets("can switch through tabs", (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
          ),
        ),
      );

      expectTab(0);
      await tapItem(tester, 1);
      expectTab(1);
      await tapItem(tester, 2);
      expectTab(2);
      await tapItem(tester, 0);
      expectTab(0);
    });

    testWidgets("runs onPressed instead of switching the tab", (tester) async {
      int count = 0;
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: [
              PersistentTabConfig(
                screen: defaultScreen(0),
                item: ItemConfig(
                  title: "Item0",
                  icon: const Icon(key: Key("Item0"), Icons.add),
                ),
              ),
              PersistentTabConfig.noScreen(
                onPressed: (context) {
                  count++;
                },
                item: ItemConfig(
                  title: "Item1",
                  icon: const Icon(key: Key("Item1"), Icons.add),
                ),
              ),
            ],
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
          ),
        ),
      );

      expectTab(0);
      await tapItem(tester, 1);
      expectTab(0);
      expect(count, 1);
    });

    group("allows changing the number of tabs", () {
      group("when adding tabs", () {
        testWidgets("after the current tab is accessible", (tester) async {
          final tabs =
              [1, 2, 3].map((id) => tabConfig(id, defaultScreen(id))).toList();

          await tester.pumpWidget(
            wrapTabView(
              (context) => PersistentTabView(
                tabs: tabs
                    .toList(), // create a copy to avoid modifying this reference
                navBarBuilder: (config) =>
                    Style1BottomNavBar(navBarConfig: config),
              ),
            ),
          );

          expectTab(1);

          tabs.add(tabConfig(4, defaultScreen(4)));

          await tester.pumpWidget(
            wrapTabView(
              (context) => PersistentTabView(
                tabs: tabs.toList(),
                navBarBuilder: (config) =>
                    Style1BottomNavBar(navBarConfig: config),
              ),
            ),
          );

          expectTab(1);

          await tapItem(tester, 4);
          expectTab(4);
        });

        testWidgets(
            "in front of the current tab is accessible and has the same index",
            (tester) async {
          final tabs =
              [1, 2, 3].map((id) => tabConfig(id, defaultScreen(id))).toList();

          await tester.pumpWidget(
            wrapTabView(
              (context) => PersistentTabView(
                tabs: tabs
                    .toList(), // create a copy to avoid modifying this reference
                navBarBuilder: (config) =>
                    Style1BottomNavBar(navBarConfig: config),
              ),
            ),
          );

          expectTab(1);

          tabs.insert(0, tabConfig(0, defaultScreen(0)));

          await tester.pumpWidget(
            wrapTabView(
              (context) => PersistentTabView(
                tabs: tabs.toList(),
                navBarBuilder: (config) =>
                    Style1BottomNavBar(navBarConfig: config),
              ),
            ),
          );

          expectTab(0);
        });
      });

      group("when removing tabs", () {
        testWidgets("they are not accessible", (tester) async {
          final tabs =
              [1, 2, 3].map((id) => tabConfig(id, defaultScreen(id))).toList();

          await tester.pumpWidget(
            wrapTabView(
              (context) => PersistentTabView(
                tabs: tabs
                    .toList(), // create a copy to avoid modifying this reference
                navBarBuilder: (config) =>
                    Style1BottomNavBar(navBarConfig: config),
              ),
            ),
          );

          expectTab(1);

          tabs.removeAt(2);

          await tester.pumpWidget(
            wrapTabView(
              (context) => PersistentTabView(
                tabs: tabs.toList(),
                navBarBuilder: (config) =>
                    Style1BottomNavBar(navBarConfig: config),
              ),
            ),
          );

          expectTab(1);

          expect(find.text("Item3"), findsNothing);
        });

        testWidgets(
            "stays on the same index (-> tab changes) when removing a tab in front of the current one",
            (tester) async {
          final tabs =
              [1, 2, 3].map((id) => tabConfig(id, defaultScreen(id))).toList();

          await tester.pumpWidget(
            wrapTabView(
              (context) => PersistentTabView(
                tabs: tabs
                    .toList(), // create a copy to avoid modifying this reference
                navBarBuilder: (config) =>
                    Style1BottomNavBar(navBarConfig: config),
              ),
            ),
          );

          await tapItem(tester, 2);
          expectTab(2);

          tabs.removeAt(0);

          await tester.pumpWidget(
            wrapTabView(
              (context) => PersistentTabView(
                tabs: tabs.toList(),
                navBarBuilder: (config) =>
                    Style1BottomNavBar(navBarConfig: config),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expectTab(3);
        });

        testWidgets(
            "jumps to the initial index when removing a tab in front of the current one and old index would be out of range",
            (tester) async {
          final tabs =
              [1, 2, 3].map((id) => tabConfig(id, defaultScreen(id))).toList();

          await tester.pumpWidget(
            wrapTabView(
              (context) => PersistentTabView(
                tabs: tabs
                    .toList(), // create a copy to avoid modifying this reference
                navBarBuilder: (config) =>
                    Style1BottomNavBar(navBarConfig: config),
              ),
            ),
          );

          await tapItem(tester, 3);
          expectTab(3);

          tabs.removeAt(0);

          await tester.pumpWidget(
            wrapTabView(
              (context) => PersistentTabView(
                tabs: tabs.toList(),
                navBarBuilder: (config) =>
                    Style1BottomNavBar(navBarConfig: config),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expectTab(2);
        });

        testWidgets(
            "jumps to the initial index when removing a tab and the new tab at that index has an onPressed callback",
            (tester) async {
          final tabs =
              [1, 2, 3].map((id) => tabConfig(id, defaultScreen(id))).toList();
          tabs[2] = PersistentTabConfig.noScreen(
            item: ItemConfig(
              title: "Item3",
              icon: const Icon(key: Key("Item3"), Icons.add),
            ),
            onPressed: (c) {},
          );

          await tester.pumpWidget(
            wrapTabView(
              (context) => PersistentTabView(
                tabs: tabs
                    .toList(), // create a copy to avoid modifying this reference
                navBarBuilder: (config) =>
                    Style1BottomNavBar(navBarConfig: config),
              ),
            ),
          );

          await tapItem(tester, 2);
          expectTab(2);

          tabs.removeAt(0);

          await tester.pumpWidget(
            wrapTabView(
              (context) => PersistentTabView(
                tabs: tabs.toList(),
                navBarBuilder: (config) =>
                    Style1BottomNavBar(navBarConfig: config),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expectTab(2);
        });

        testWidgets(
            "jumps to the first possible tab if the initial index has an onPressed callback after removing a tab and the new tab at that index also has an onPressed callback",
            (tester) async {
          final tabs =
              [1, 2, 3].map((id) => tabConfig(id, defaultScreen(id))).toList();
          tabs[1] = PersistentTabConfig.noScreen(
            item: ItemConfig(
              title: "Item2",
              icon: const Icon(key: Key("Item2"), Icons.add),
            ),
            onPressed: (c) {},
          );

          await tester.pumpWidget(
            wrapTabView(
              (context) => PersistentTabView(
                tabs: tabs
                    .toList(), // create a copy to avoid modifying this reference
                navBarBuilder: (config) =>
                    Style1BottomNavBar(navBarConfig: config),
              ),
            ),
          );

          expectTab(1);

          tabs.removeAt(0);

          await tester.pumpWidget(
            wrapTabView(
              (context) => PersistentTabView(
                tabs: tabs.toList(),
                navBarBuilder: (config) =>
                    Style1BottomNavBar(navBarConfig: config),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expectTab(3);
        });
      });
    });

    testWidgets("hides the navbar when hideNavBar is true", (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            hideNavigationBar: true,
          ),
        ),
      );

      expect(find.byType(DecoratedNavBar).hitTestable(), findsNothing);
    });

    testWidgets("changes hideNavBar status at runtime", (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            hideNavigationBar: false,
          ),
        ),
      );

      expect(find.byType(DecoratedNavBar).hitTestable(), findsOneWidget);

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            hideNavigationBar: true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DecoratedNavBar).hitTestable(), findsNothing);

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            hideNavigationBar: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DecoratedNavBar).hitTestable(), findsOneWidget);
    });

    testWidgets("sizes the navbar according to the height", (tester) async {
      const double height = 60;

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(
              navBarConfig: config,
              height: height,
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(DecoratedNavBar)).height,
        equals(height),
      );
    });

    testWidgets("puts no padding around the navbar when margin is zero",
        (tester) async {
      const margin = EdgeInsets.zero;

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            margin: margin,
          ),
        ),
      );

      expect(
        const Offset(0, 600) -
            tester.getBottomLeft(find.byType(DecoratedNavBar)),
        equals(margin.bottomLeft),
      );
      expect(
        Offset(800, 600 - tester.getSize(find.byType(DecoratedNavBar)).height) -
            tester.getTopRight(find.byType(DecoratedNavBar)),
        equals(margin.topRight),
      );
    });

    testWidgets("puts padding around the navbar when margin is set",
        (tester) async {
      EdgeInsets margin = EdgeInsets.zero;

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            margin: margin,
          ),
        ),
      );

      expect(
        const Offset(0, 600) -
            tester.getBottomLeft(find.byType(DecoratedNavBar)),
        equals(margin.bottomLeft),
      );
      expect(
        Offset(800, 600 - tester.getSize(find.byType(DecoratedNavBar)).height) -
            tester.getTopRight(find.byType(DecoratedNavBar)),
        equals(margin.topRight),
      );

      margin = const EdgeInsets.fromLTRB(12, 10, 8, 6);

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            margin: margin,
          ),
        ),
      );

      expect(
        tester.getBottomLeft(
              find
                  .descendant(
                    of: find.byType(DecoratedNavBar),
                    matching: find.byType(Container),
                  )
                  .first,
            ) -
            const Offset(0, 600),
        equals(margin.bottomLeft),
      );
      expect(
        tester.getTopRight(
              find
                  .descendant(
                    of: find.byType(DecoratedNavBar),
                    matching: find.byType(Container),
                  )
                  .first,
            ) -
            Offset(
              800,
              600 -
                  tester.getSize(find.byType(DecoratedNavBar)).height -
                  margin.vertical,
            ),
        equals(margin.topRight),
      );
    });

    testWidgets("navbar is colored by decoration color", (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(
              navBarConfig: config,
              navBarDecoration:
                  const NavBarDecoration(color: Color(0xFFFFC107)),
            ),
          ),
        ),
      );

      expect(
        ((tester.firstWidget(
          find.descendant(
            of: find.byType(DecoratedNavBar),
            matching: find.byType(DecoratedBox),
          ),
        ) as DecoratedBox?)
                ?.decoration as BoxDecoration?)
            ?.color,
        const Color(0xFFFFC107),
      );
    });

    testWidgets("navbar applies filter if color is (partially) transparent",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(
              navBarConfig: config,
              navBarDecoration: NavBarDecoration(
                color: const Color.fromARGB(45, 255, 193, 7),
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets("executes onItemSelected when tapping items", (tester) async {
      int count = 0;

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            onTabChanged: (index) => count++,
          ),
        ),
      );

      await tapItem(tester, 1);
      expect(count, 1);
      await tapItem(tester, 2);
      expect(count, 2);
    });

    testWidgets(
        "executes onPopInvokedWithResult of enclosing PopScope when exiting",
        (tester) async {
      bool? popResult;

      await tester.pumpWidget(
        wrapTabView(
          (context) => PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              popResult = didPop;
            },
            child: PersistentTabView(
              tabs: tabs(),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        ),
      );

      await tapAndroidBackButton(tester);

      expect(popResult, false);
    });

    group("should handle Android back button press and thus", () {
      testWidgets("switches to first tab on back button press", (tester) async {
        await tester.pumpWidget(
          wrapTabView(
            (context) => PersistentTabView(
              tabs: tabs(),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        expectTab(0);
        await tapItem(tester, 1);
        expectTab(1);
        await tapAndroidBackButton(tester);
        expectTab(0);
      });

      testWidgets("pops one screen on back button press", (tester) async {
        await tester.pumpWidget(
          wrapTabView(
            (context) => PersistentTabView(
              tabs: tabs(),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        await tapElevatedButton(tester);
        expectTab(0, level: 1);

        await tapAndroidBackButton(tester);
        expectTab(0);
      });

      testWidgets("pops main screen when historyLength is 0", (tester) async {
        await tester.pumpWidget(
          wrapTabViewWithMainScreen(
            (context) => PersistentTabView(
              controller: PersistentTabController(historyLength: 0),
              tabs: tabs(),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        await tapElevatedButton(tester);
        expectTab(0);

        await tapItem(tester, 1);
        expectTab(1);

        await tapAndroidBackButton(tester);
        expectMainScreen();
      });

      testWidgets("pops main screen when historyLength is 1", (tester) async {
        await tester.pumpWidget(
          wrapTabViewWithMainScreen(
            (context) => PersistentTabView(
              controller: PersistentTabController(historyLength: 1),
              tabs: tabs(),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        await tapElevatedButton(tester);
        expectTab(0);

        await tapItem(tester, 1);
        expectTab(1);

        await tapAndroidBackButton(tester);
        expectTab(0);

        await tapAndroidBackButton(tester);
        expectMainScreen();
      });

      testWidgets(
          "pops main screen when historyLength is 1 and switched to initial tab",
          (tester) async {
        await tester.pumpWidget(
          wrapTabViewWithMainScreen(
            (context) => PersistentTabView(
              controller: PersistentTabController(historyLength: 1),
              tabs: tabs(),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        await tapElevatedButton(tester);
        expectTab(0);

        await tapItem(tester, 1);
        expectTab(1);

        await tapItem(tester, 0);
        expectTab(0);

        await tapAndroidBackButton(tester);
        expectMainScreen();
      });

      testWidgets(
          "pops main screen when historyLength is 1 and initial tab has subpage",
          (tester) async {
        await tester.pumpWidget(
          wrapTabViewWithMainScreen(
            (context) => PersistentTabView(
              controller: PersistentTabController(historyLength: 1),
              tabs: tabs(),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        await tapElevatedButton(tester);
        expectTab(0);

        await tapElevatedButton(tester);
        expectTab(0, level: 1);

        await tapItem(tester, 1);
        expectTab(1);

        await tapAndroidBackButton(tester);
        expectTab(0, level: 1);

        await tapAndroidBackButton(tester);
        expectTab(0);

        await tapAndroidBackButton(tester);
        expectMainScreen();
      });

      testWidgets("pops main screen when historyLength is 2", (tester) async {
        await tester.pumpWidget(
          wrapTabViewWithMainScreen(
            (context) => PersistentTabView(
              controller: PersistentTabController(historyLength: 2),
              tabs: tabs(),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        await tapElevatedButton(tester);
        expectTab(0);

        await tapItem(tester, 1);
        expectTab(1);

        await tapItem(tester, 2);
        expectTab(2);

        await tapAndroidBackButton(tester);
        expectTab(1);

        await tapAndroidBackButton(tester);
        expectTab(0);

        await tapAndroidBackButton(tester);
        expectMainScreen();
      });

      testWidgets(
          "pops main screen when historyLength is 2 and clearing history",
          (tester) async {
        await tester.pumpWidget(
          wrapTabViewWithMainScreen(
            (context) => PersistentTabView(
              controller: PersistentTabController(
                historyLength: 2,
                clearHistoryOnInitialIndex: true,
              ),
              tabs: tabs(),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        await tapElevatedButton(tester);
        expectTab(0);

        await tapItem(tester, 1);
        expectTab(1);

        await tapItem(tester, 0);
        expectTab(0);

        await tapAndroidBackButton(tester);
        expectMainScreen();
      });

      testWidgets(
          "pops main screen when historyLength is 2 and clears repeating tabs in history",
          (tester) async {
        await tester.pumpWidget(
          wrapTabViewWithMainScreen(
            (context) => PersistentTabView(
              controller: PersistentTabController(historyLength: 2),
              tabs: tabs(),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        await tapElevatedButton(tester);
        expectTab(0);

        await tapItem(tester, 1);
        expectTab(1);

        await tapItem(tester, 0);
        expectTab(0);

        await tapItem(tester, 1);
        expectTab(1);

        await tapAndroidBackButton(tester);
        await tapAndroidBackButton(tester);
        expectMainScreen();
      });
    });

    testWidgets("controller can open drawer", (tester) async {
      final controller = PersistentTabController();

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            controller: controller,
            tabs: tabs(),
            drawer: const Drawer(child: Text("Drawer")),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
          ),
        ),
      );

      controller.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text("Drawer"), findsOneWidget);
    });

    group("should not handle Android back button press and thus", () {
      testWidgets("does not switch the tab on back button press",
          (tester) async {
        await tester.pumpWidget(
          wrapTabView(
            (context) => PersistentTabView(
              tabs: tabs(),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
              handleAndroidBackButtonPress: false,
            ),
          ),
        );

        expectTab(0);
        await tapItem(tester, 1);
        expectTab(1);

        await tapAndroidBackButton(tester);

        expectTab(1);
      });

      testWidgets("pops no screen on back button press", (tester) async {
        await tester.pumpWidget(
          wrapTabView(
            (context) => PersistentTabView(
              tabs: tabs(),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
              handleAndroidBackButtonPress: false,
            ),
          ),
        );

        await tapElevatedButton(tester);
        expectTab(0, level: 1);

        await tapAndroidBackButton(tester);

        expectTab(0, level: 1);
      });
    });

    group("handles altering tabs at runtime when", () {
      testWidgets("removing tabs", (tester) async {
        final List<PersistentTabConfig> localTabs = tabs();

        await tester.pumpWidget(
          wrapTabView(
            (context) => PersistentTabView(
              tabs: localTabs,
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        expectTab(0);
        expect(find.byType(Icon), findsNWidgets(3));

        localTabs.removeAt(0);
        await tester.pumpWidget(
          wrapTabView(
            (context) => PersistentTabView(
              tabs: localTabs,
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );
        await tester.pump();

        expectTab(1);
        expect(find.byType(Icon), findsNWidgets(2));
      });

      testWidgets("removing and re-adding tabs", (tester) async {
        final List<PersistentTabConfig> localTabs = tabs();

        await tester.pumpWidget(
          wrapTabView(
            (context) => PersistentTabView(
              tabs: localTabs,
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        expectTab(0);
        expect(find.byType(Icon), findsNWidgets(3));

        localTabs.removeAt(0);
        await tester.pumpWidget(
          wrapTabView(
            (context) => PersistentTabView(
              tabs: localTabs,
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );
        await tester.pump();

        expectTab(1);
        expect(find.byType(Icon), findsNWidgets(2));

        localTabs.insert(0, tabConfig(0, defaultScreen(0)));

        await tester.pumpWidget(
          wrapTabView(
            (context) => PersistentTabView(
              tabs: localTabs,
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );
        await tester.pump();

        expectTab(0);
        expect(find.byType(Icon), findsNWidgets(3));
      });
    });

    testWidgets(
        "hides nav bar after the specified amount of pixels have been scrolled",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: List.generate(3, (id) => tabConfig(id, scrollableScreen(id))),
            navBarBuilder: (config) => Style1BottomNavBar(
              navBarConfig: config,
            ),
            hideOnScrollVelocity: 200,
          ),
        ),
      );

      final initialHeight =
          tester.getSize(find.byType(DecoratedNavBar).first).height;

      await scroll(tester, const Offset(0, 200), const Offset(0, -100));

      expect(
        find.byType(DecoratedNavBar).hitTestable(at: Alignment.topCenter),
        findsOneWidget,
      );
      expect(
        (tester.getRect(find.byType(DecoratedNavBar).first).bottom - 600)
            .toStringAsPrecision(2),
        equals(
          (Curves.ease.transform(0.5) * initialHeight).toStringAsPrecision(2),
        ),
      );

      await scroll(tester, const Offset(0, 200), const Offset(0, -100));
      expect(
        tester.getRect(find.byType(DecoratedNavBar).first).bottom - 600,
        equals(initialHeight),
      );

      expect(find.byType(DecoratedNavBar).hitTestable(), findsNothing);
      await scroll(tester, const Offset(0, 200), const Offset(0, 200));

      expect(find.byType(DecoratedNavBar).hitTestable(), findsOneWidget);
      expect(
        tester.getSize(find.byType(DecoratedNavBar).first).height,
        equals(initialHeight),
      );
      expect(
        tester.getRect(find.byType(DecoratedNavBar).first).bottom - 600,
        equals(0),
      );
    });

    testWidgets("navBarPadding adds padding inside navBar", (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(
              navBarConfig: config,
              navBarDecoration:
                  const NavBarDecoration(padding: EdgeInsets.zero),
            ),
          ),
        ),
      );
      final double originalHeight =
          tester.getSize(find.byType(DecoratedNavBar).first).height;

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(
              navBarConfig: config,
              navBarDecoration:
                  const NavBarDecoration(padding: EdgeInsets.all(4)),
            ),
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(DecoratedNavBar).first).height,
        equals(originalHeight + 4 * 2),
      );
    });

    testWidgets(
        "navBarPadding does not make navbar bigger when height is fixed",
        (tester) async {
      const double height = kBottomNavigationBarHeight;

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(
              navBarConfig: config,
              navBarDecoration:
                  const NavBarDecoration(padding: EdgeInsets.all(4)),
              height: height,
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(DecoratedNavBar)).height,
        equals(height),
      );
    });

    testWidgets(
        "resizes screens to avoid bottom inset according to resizeToAvoidBottomInset",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => MediaQuery(
            data: const MediaQueryData(
              viewInsets:
                  EdgeInsets.only(bottom: 100), // Simulate an open keyboard
            ),
            child: Builder(
              builder: (context) => PersistentTabView(
                tabs: tabs(),
                navBarBuilder: (config) =>
                    Style1BottomNavBar(navBarConfig: config),
              ),
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(CustomTabView).first).height,
        equals(500),
      );

      await tester.pumpWidget(
        wrapTabView(
          (context) => MediaQuery(
            data: const MediaQueryData(
              viewInsets:
                  EdgeInsets.only(bottom: 100), // Simulate an open keyboard
            ),
            child: Builder(
              builder: (context) => PersistentTabView(
                tabs: tabs(),
                navBarBuilder: (config) =>
                    Style1BottomNavBar(navBarConfig: config),
                resizeToAvoidBottomInset: false,
              ),
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(CustomTabView).first).height,
        equals(600 - tester.getSize(find.byType(DecoratedNavBar)).height),
      );
    });

    testWidgets("shrinks screens according to NavBarOverlap.custom",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            navBarOverlap: const NavBarOverlap.full(),
          ),
        ),
      );

      final navbarHeight = tester.getSize(find.byType(DecoratedNavBar)).height;

      expect(
        tester.getSize(find.byType(CustomTabView).first).height,
        equals(600),
      );

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(CustomTabView).first).height,
        equals(600 - navbarHeight),
      );

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            navBarOverlap: const NavBarOverlap.custom(overlap: 30),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(CustomTabView).first).height,
        equals(600 - (navbarHeight - 30)),
      );
    });

    testWidgets(
        "doesnt pop any screen when tapping same tab when `selectedTabPressConfig.popAction == PopActionType.none`",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            selectedTabPressConfig: const SelectedTabPressConfig(
              popAction: PopActionType.none,
            ),
          ),
        ),
      );

      await tapElevatedButton(tester);
      expectTab(0, level: 1);
      await tapItem(tester, 0);
      expectTab(0, level: 1);
    });

    testWidgets(
        "pops all screens when tapping same tab when `selectedTabPressConfig.popAction == PopActionType.all`",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            selectedTabPressConfig: const SelectedTabPressConfig(
              popAction: PopActionType.all,
            ),
          ),
        ),
      );

      await tapElevatedButton(tester);
      expectTab(0, level: 1);
      await tapElevatedButton(tester);
      expectTab(0, level: 2);
      await tapItem(tester, 0);
      expectTab(0);
    });

    testWidgets(
        "pops a single screen when tapping same tab when `selectedTabPressConfig.popAction == PopActionType.single`",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            selectedTabPressConfig: const SelectedTabPressConfig(
              popAction: PopActionType.single,
            ),
          ),
        ),
      );

      await tapElevatedButton(tester);
      expectTab(0, level: 1);
      await tapElevatedButton(tester);
      expectTab(0, level: 2);
      await tapItem(tester, 0);
      expectTab(0, level: 1);
    });

    testWidgets(
        "runs callback when selected tab is tapped again and there are no screens pushed",
        (tester) async {
      bool callbackGotExecuted = false;
      bool areScreensPushed = false;

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            selectedTabPressConfig: SelectedTabPressConfig(
              onPressed: (hasPages) {
                areScreensPushed = hasPages;
                callbackGotExecuted = true;
              },
            ),
          ),
        ),
      );

      expectTab(0);
      await tapItem(tester, 0);
      expect(areScreensPushed, equals(false));
      expect(callbackGotExecuted, equals(true));
    });

    testWidgets(
        "runs callback when selected tab is tapped again and there are screens pushed",
        (tester) async {
      bool callbackGotExecuted = false;
      bool areScreensPushed = false;

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            selectedTabPressConfig: SelectedTabPressConfig(
              onPressed: (hasPages) {
                areScreensPushed = hasPages;
                callbackGotExecuted = true;
              },
            ),
          ),
        ),
      );

      await tapElevatedButton(tester);
      expectTab(0, level: 1);
      await tapItem(tester, 0);
      expect(areScreensPushed, equals(true));
      expect(callbackGotExecuted, equals(true));
    });

    testWidgets(
        "scrolls the tab content to top when the selected tab is tapped again and it is enabled",
        (tester) async {
      final controllers = [
        ScrollController(),
        ScrollController(),
        ScrollController(),
      ];

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: List.generate(
              3,
              (id) => tabConfig(
                id,
                scrollableScreen(
                  id,
                  controller: controllers[id],
                ),
                controllers[id],
              ),
            ),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            selectedTabPressConfig: const SelectedTabPressConfig(
              scrollToTop: true,
            ),
          ),
        ),
      );

      await scroll(tester, const Offset(0, 200), const Offset(0, -400));

      expectNotTab(0);

      await tapItem(tester, 0);

      expectTab(0);
      expect(controllers[0].offset, equals(0));
    });

    testWidgets(
        "does not scroll the tab content to top when the selected tab is tapped again when it is disabled",
        (tester) async {
      final controllers = [
        ScrollController(),
        ScrollController(),
        ScrollController(),
      ];

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: List.generate(
              3,
              (id) => tabConfig(
                id,
                scrollableScreen(
                  id,
                  controller: controllers[id],
                ),
                controllers[id],
              ),
            ),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            selectedTabPressConfig: const SelectedTabPressConfig(
              scrollToTop: false,
            ),
          ),
        ),
      );

      await scroll(tester, const Offset(0, 200), const Offset(0, -400));

      expectNotTab(0);

      await tapItem(tester, 0);

      expectNotTab(0);
      expect(controllers[0].offset, isNot(0));
    });

    testWidgets(
        "scrollToTop is enabled but switching to a new tab does not scroll immediately",
        (tester) async {
      final controllers = [
        ScrollController(),
        ScrollController(),
        ScrollController(),
      ];

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: List.generate(
              3,
              (id) => tabConfig(
                id,
                scrollableScreen(
                  id,
                  controller: controllers[id],
                ),
                controllers[id],
              ),
            ),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            selectedTabPressConfig: const SelectedTabPressConfig(
              scrollToTop: true,
            ),
          ),
        ),
      );

      await scroll(tester, const Offset(0, 200), const Offset(0, -400));

      expectNotTab(0);

      await tapItem(tester, 1);
      await tapItem(tester, 0);

      expectNotTab(0);
      expect(controllers[0].offset, isNot(0));
    });

    testWidgets(
        "does keep navigator history when `keepNaviagotHistory == true`",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            keepNavigatorHistory: true,
          ),
        ),
      );

      await tapElevatedButton(tester);
      expectTab(0, level: 1);
      await tapItem(tester, 1);
      await tapItem(tester, 0);
      expectTab(0, level: 1);
    });

    testWidgets(
        "doesnt keep any navigator history when `keepNaviagotHistory == false`",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            keepNavigatorHistory: false,
          ),
        ),
      );

      await tapElevatedButton(tester);
      expectTab(0, level: 1);
      await tapItem(tester, 1);
      await tapItem(tester, 0);
      expectTab(0);
    });

    testWidgets("persists screens while switching if stateManagement turned on",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
          ),
        ),
      );

      await tapElevatedButton(tester);
      expectTab(0, level: 1);
      await tapItem(tester, 1);
      expectTab(1);
      await tapItem(tester, 0);
      expectTab(0, level: 1);
    });

    testWidgets("trashes screens while switching if stateManagement turned off",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            stateManagement: false,
          ),
        ),
      );

      await tapElevatedButton(tester);
      expectTab(0, level: 1);
      await tapItem(tester, 1);
      expectTab(1);
      await tapItem(tester, 0);
      expectTab(0);
    });

    testWidgets(
        "changes animation direction when switching tabs if TextDirection is RTL",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: PersistentTabView(
              tabs: tabs(),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        ),
      );

      expectTab(0);
      await tester.tap(find.text("Item1"));
      await tester.pump(Durations.short1);
      await tester.pump(Durations.short1);
      // 400 is the horizontal center of the screen, so tab 0 should leave towards the right and tab 1 should enter from the left
      expect(tester.getCenter(find.text("Tab 0")).dx, greaterThan(400));
      expect(tester.getCenter(find.text("Tab 1")).dx, lessThan(400));
      await tester.pumpAndSettle();
      expectTab(1);
    });

    testWidgets("custom animated builder", (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            animatedTabBuilder:
                (context, index, animation, oldTabIndex, newTabIndex, child) {
              final double yOffset = newTabIndex > index
                  ? -animation
                  : (newTabIndex < index
                      ? animation
                      : (index < oldTabIndex ? animation - 1 : 1 - animation));
              return FractionalTranslation(
                translation: Offset(yOffset, 0),
                child: child,
              );
            },
          ),
        ),
      );

      expectTab(0);
      await tester.tap(find.text("Item1"));
      await tester.pump(Durations.short1);
      await tester.pump(Durations.short1);
      // 400 is the horizontal center of the screen, so tab 0 should leave towards the left and tab 1 should enter from the right
      expect(tester.getCenter(find.text("Tab 0")).dx, lessThan(400));
      expect(tester.getCenter(find.text("Tab 1")).dx, greaterThan(400));
      await tester.pumpAndSettle();
      expectTab(1);
    });

    testWidgets("no animation when ScreenTransitionAnimation.none()",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            screenTransitionAnimation: const ScreenTransitionAnimation.none(),
          ),
        ),
      );

      expectTab(0);
      await tester.tap(find.text("Item1"));
      await tester.pump();
      expectTab(1);
    });

    testWidgets("shows FloatingActionButton if specified", (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton).hitTestable(), findsOneWidget);
    });

    testWidgets("changes screens on gestures", (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            gestureNavigationEnabled: true,
          ),
        ),
      );

      await tester.fling(
        find.byType(PersistentTabView),
        const Offset(-200, 0),
        800,
      );
      await tester.pumpAndSettle();

      expectTab(1);
    });

    testWidgets("changes screens programmatically when gestures are enabled",
        (tester) async {
      final controller = PersistentTabController();

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            controller: controller,
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            gestureNavigationEnabled: true,
          ),
        ),
      );

      controller.jumpToTab(1);
      await tester.pumpAndSettle();

      expectTab(1);
    });

    testWidgets(
        "trashes screens while switching if stateManagement turned off with gestures enabled",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            stateManagement: false,
            gestureNavigationEnabled: true,
          ),
        ),
      );

      await tapElevatedButton(tester);
      expectTab(0, level: 1);
      await tapItem(tester, 1);
      expectTab(1);
      await tapItem(tester, 0);
      expectTab(0);
    });

    testWidgets(
        "persists screens while switching if stateManagement turned on with gestures enabled",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
            stateManagement: true,
            gestureNavigationEnabled: true,
          ),
        ),
      );

      await tapElevatedButton(tester);
      expectTab(0, level: 1);
      await tapItem(tester, 1);
      expectTab(1);
      await tapItem(tester, 0);
      expectTab(0, level: 1);
    });

    testWidgets(
        "Style 13 and Style 14 center button are tappable above the navBar",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) =>
                Style13BottomNavBar(navBarConfig: config),
          ),
        ),
      );

      Offset topCenter = tester.getRect(find.byType(DecoratedNavBar)).topCenter;
      await tester.tapAt(topCenter.translate(0, -10));
      await tester.pumpAndSettle();
      expectTab(1);

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) =>
                Style14BottomNavBar(navBarConfig: config),
          ),
        ),
      );

      topCenter = tester.getRect(find.byType(DecoratedNavBar)).topCenter;
      await tester.tapAt(topCenter.translate(0, -10));
      await tester.pumpAndSettle();
      expectTab(1);
    });

    testWidgets("automatically animates animated icons", (tester) async {
      final keys = [
        GlobalKey<AnimatedIconWrapperState>(),
        GlobalKey<AnimatedIconWrapperState>(),
        GlobalKey<AnimatedIconWrapperState>(),
      ];

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: List.generate(
              3,
              (id) => PersistentTabConfig(
                screen: defaultScreen(id),
                item: ItemConfig(
                  title: "Item$id",
                  icon: AnimatedIconWrapper(
                    icon: AnimatedIcons.add_event,
                    key: keys[id],
                  ),
                ),
              ),
            ),
            navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(keys[0].currentState!.controller.value, equals(1));
      expect(keys[1].currentState!.controller.value, equals(0));
      await tester.tap(find.text("Item1"));
      await tester.pumpAndSettle();

      expect(keys[0].currentState!.controller.value, equals(0));
      expect(keys[1].currentState!.controller.value, equals(1));
    });

    group("uses navigator config", () {
      testWidgets("to populate routes of each tab navigator", (tester) async {
        await tester.pumpWidget(
          wrapTabView(
            (context) => PersistentTabView(
              tabs: List.generate(
                3,
                (id) => PersistentTabConfig(
                  screen: defaultScreen(
                    id,
                    onTap: (context) {
                      Navigator.of(context).pushNamed("/details");
                    },
                  ),
                  item: ItemConfig(
                    title: "Item$id",
                    icon: Icon(key: Key("Item$id"), Icons.add),
                  ),
                  navigatorConfig: NavigatorConfig(
                    routes: {
                      "/details": (context) => defaultScreen(id, level: 1),
                    },
                  ),
                ),
              ),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        await tapElevatedButton(tester);
        expectTab(0, level: 1);
        await tapItem(tester, 1);
        await tapElevatedButton(tester);
        expectTab(1, level: 1);
        await tapItem(tester, 2);
        await tapElevatedButton(tester);
        expectTab(2, level: 1);
      });

      testWidgets("to run onGenerateRoute of each tab navigator",
          (tester) async {
        await tester.pumpWidget(
          wrapTabView(
            (context) => PersistentTabView(
              tabs: List.generate(
                3,
                (id) => PersistentTabConfig(
                  screen: defaultScreen(
                    id,
                    onTap: (context) {
                      Navigator.of(context).pushNamed("/details");
                    },
                  ),
                  item: ItemConfig(
                    title: "Item$id",
                    icon: Icon(key: Key("Item$id"), Icons.add),
                  ),
                  navigatorConfig: NavigatorConfig(
                    onGenerateRoute: (settings) => MaterialPageRoute(
                      builder: (context) => defaultScreen(id, level: 1),
                    ),
                  ),
                ),
              ),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        await tapElevatedButton(tester);
        expectTab(0, level: 1);
        await tapItem(tester, 1);
        await tapElevatedButton(tester);
        expectTab(1, level: 1);
        await tapItem(tester, 2);
        await tapElevatedButton(tester);
        expectTab(2, level: 1);
      });

      testWidgets("to run onUnknownRoute of each tab navigator",
          (tester) async {
        await tester.pumpWidget(
          wrapTabView(
            (context) => PersistentTabView(
              tabs: List.generate(
                3,
                (id) => PersistentTabConfig(
                  screen: defaultScreen(
                    id,
                    onTap: (context) {
                      Navigator.of(context).pushNamed("/unknown-route");
                    },
                  ),
                  item: ItemConfig(
                    title: "Item$id",
                    icon: Icon(key: Key("Item$id"), Icons.add),
                  ),
                  navigatorConfig: NavigatorConfig(
                    onUnknownRoute: (settings) => MaterialPageRoute(
                      builder: (context) => defaultScreen(id, level: -1),
                    ),
                  ),
                ),
              ),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        await tapElevatedButton(tester);
        expectTab(0, level: -1);
        await tapItem(tester, 1);
        await tapElevatedButton(tester);
        expectTab(1, level: -1);
        await tapItem(tester, 2);
        await tapElevatedButton(tester);
        expectTab(2, level: -1);
      });

      testWidgets("to report missing onUnknownRoute as error", (tester) async {
        await tester.pumpWidget(
          wrapTabView(
            (context) => PersistentTabView(
              tabs: List.generate(
                3,
                (id) => PersistentTabConfig(
                  screen: defaultScreen(
                    id,
                    onTap: (context) {
                      Navigator.of(context).pushNamed("/unknown-route");
                    },
                  ),
                  item: ItemConfig(
                    title: "Item$id",
                    icon: Icon(key: Key("Item$id"), Icons.add),
                  ),
                ),
              ),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        await tapElevatedButton(tester);
        final exception = tester.takeException();
        expect(exception, isFlutterError);
      });

      testWidgets("to report onUnknownRoute returning null as error",
          (tester) async {
        await tester.pumpWidget(
          wrapTabView(
            (context) => PersistentTabView(
              tabs: List.generate(
                3,
                (id) => PersistentTabConfig(
                  screen: defaultScreen(
                    id,
                    onTap: (context) {
                      Navigator.of(context).pushNamed("/unknown-route");
                    },
                  ),
                  item: ItemConfig(
                    title: "Item$id",
                    icon: Icon(key: Key("Item$id"), Icons.add),
                  ),
                  navigatorConfig: NavigatorConfig(
                    onUnknownRoute: (settings) => null,
                  ),
                ),
              ),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        await tapElevatedButton(tester);
        final exception = tester.takeException();
        expect(exception, isFlutterError);
      });
    });

    group("uses root navigator", () {
      testWidgets("to populate routes of each tab navigator", (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            routes: {
              "/details": (context) => defaultScreen(0, level: 1),
            },
            home: PersistentTabView(
              tabs: List.generate(
                3,
                (id) => PersistentTabConfig(
                  screen: defaultScreen(
                    id,
                    onTap: (context) {
                      Navigator.of(context).pushNamed("/details");
                    },
                  ),
                  item: ItemConfig(
                    title: "Item$id",
                    icon: Icon(key: Key("Item$id"), Icons.add),
                  ),
                ),
              ),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        await tapElevatedButton(tester);
        expectTab(0, level: 1);
        await tapItem(tester, 1);
        await tapElevatedButton(tester);
        expectTab(0, level: 1);
        await tapItem(tester, 2);
        await tapElevatedButton(tester);
        expectTab(0, level: 1);
      });

      testWidgets("to run onGenerateRoute of each tab navigator",
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => defaultScreen(0, level: 1),
            ),
            home: PersistentTabView(
              tabs: List.generate(
                3,
                (id) => PersistentTabConfig(
                  screen: defaultScreen(
                    id,
                    onTap: (context) {
                      Navigator.of(context).pushNamed("/details");
                    },
                  ),
                  item: ItemConfig(
                    title: "Item$id",
                    icon: Icon(key: Key("Item$id"), Icons.add),
                  ),
                ),
              ),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        await tapElevatedButton(tester);
        expectTab(0, level: 1);
        await tapItem(tester, 1);
        await tapElevatedButton(tester);
        expectTab(0, level: 1);
        await tapItem(tester, 2);
        await tapElevatedButton(tester);
        expectTab(0, level: 1);
      });

      testWidgets("to report missing onUnknownRoute as error", (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: PersistentTabView(
              tabs: List.generate(
                3,
                (id) => PersistentTabConfig(
                  screen: defaultScreen(
                    id,
                    onTap: (context) {
                      Navigator.of(context).pushNamed("/unknown-route");
                    },
                  ),
                  item: ItemConfig(
                    title: "Item$id",
                    icon: Icon(key: Key("Item$id"), Icons.add),
                  ),
                ),
              ),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        await tapElevatedButton(tester);
        final exception = tester.takeException();
        expect(exception, isFlutterError);
      });

      testWidgets("to report onUnknownRoute returning null as error",
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: (settings) => null,
            home: PersistentTabView(
              tabs: List.generate(
                3,
                (id) => PersistentTabConfig(
                  screen: defaultScreen(
                    id,
                    onTap: (context) {
                      Navigator.of(context).pushNamed("/unknown-route");
                    },
                  ),
                  item: ItemConfig(
                    title: "Item$id",
                    icon: Icon(key: Key("Item$id"), Icons.add),
                  ),
                ),
              ),
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        );

        await tapElevatedButton(tester);
        final exception = tester.takeException();
        expect(exception, isFlutterError);
      });
    });
  });

  group("PersistentTabView.router", () {
    testWidgets("can switch tabs", (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: wrapWithGoRouter(
            (context, state, shell) => PersistentTabView.router(
              tabs: routerTabs(),
              navigationShell: shell,
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        ),
      );

      expectTab(0);
      await tapItem(tester, 1);
      expectTab(1);
    });

    testWidgets("switches tabs when triggered by go_router", (tester) async {
      final router = wrapWithGoRouter(
        (context, state, shell) => PersistentTabView.router(
          tabs: routerTabs(),
          navigationShell: shell,
          navBarBuilder: (config) => Style1BottomNavBar(navBarConfig: config),
        ),
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expectTab(0);
      router.go("/tab-1");
      await tester.pumpAndSettle();
      expectTab(1);
    });

    testWidgets(
        "doesnt pop any screen when tapping same tab when `selectedTabPressConfig.popAction == PopActionType.none`",
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: wrapWithGoRouter(
            (context, state, shell) => PersistentTabView.router(
              tabs: routerTabs(),
              selectedTabPressConfig: const SelectedTabPressConfig(
                popAction: PopActionType.none,
              ),
              navigationShell: shell,
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        ),
      );

      await tapElevatedButton(tester);
      expectTab(0, level: 1);
      await tapItem(tester, 0);
      expectTab(0, level: 1);
    });

    testWidgets(
        "runs callback when selected tab is tapped again and there are no screens pushed",
        (tester) async {
      bool callbackGotExecuted = false;

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: wrapWithGoRouter(
            (context, state, shell) => PersistentTabView.router(
              tabs: routerTabs(),
              selectedTabPressConfig: SelectedTabPressConfig(
                onPressed: (hasPages) {
                  callbackGotExecuted = true;
                },
              ),
              navigationShell: shell,
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
          ),
        ),
      );

      expectTab(0);
      await tapItem(tester, 0);
      expect(callbackGotExecuted, equals(true));
    });

    testWidgets(
        "scrolls the tab content to top when the selected tab is tapped again and it is enabled",
        (tester) async {
      final controllers = [
        ScrollController(),
        ScrollController(),
        ScrollController(),
      ];

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: wrapWithGoRouter(
            (context, state, shell) => PersistentTabView.router(
              tabs: routerTabs(3, controllers),
              selectedTabPressConfig: const SelectedTabPressConfig(
                scrollToTop: true,
              ),
              navigationShell: shell,
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
            scrollControllers: controllers,
          ),
        ),
      );

      await scroll(tester, const Offset(0, 200), const Offset(0, -400));

      expectNotTab(0);

      await tapItem(tester, 0);

      expectTab(0);
      expect(controllers[0].offset, equals(0));
    });

    testWidgets(
        "does not scroll the tab content to top when the selected tab is tapped again when it is disabled",
        (tester) async {
      final controllers = [
        ScrollController(),
        ScrollController(),
        ScrollController(),
      ];

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: wrapWithGoRouter(
            (context, state, shell) => PersistentTabView.router(
              tabs: routerTabs(3, controllers),
              selectedTabPressConfig: const SelectedTabPressConfig(
                scrollToTop: false,
              ),
              navigationShell: shell,
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
            scrollControllers: controllers,
          ),
        ),
      );

      await scroll(tester, const Offset(0, 200), const Offset(0, -400));

      expectNotTab(0);

      await tapItem(tester, 0);

      expectNotTab(0);
      expect(controllers[0].offset, isNot(0));
    });

    testWidgets(
        "scrollToTop is enabled but switching to a new tab does not scroll immediately",
        (tester) async {
      final controllers = [
        ScrollController(),
        ScrollController(),
        ScrollController(),
      ];

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: wrapWithGoRouter(
            (context, state, shell) => PersistentTabView.router(
              tabs: routerTabs(3, controllers),
              selectedTabPressConfig: const SelectedTabPressConfig(
                scrollToTop: true,
              ),
              navigationShell: shell,
              navBarBuilder: (config) =>
                  Style1BottomNavBar(navBarConfig: config),
            ),
            scrollControllers: controllers,
          ),
        ),
      );

      await scroll(tester, const Offset(0, 200), const Offset(0, -400));

      expectNotTab(0);

      await tapItem(tester, 1);
      await tapItem(tester, 0);

      expectNotTab(0);
      expect(controllers[0].offset, isNot(0));
    });
  });

  group("Regression", () {
    testWidgets("#31 one navbar border side does not throw error",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(
              navBarConfig: config,
              navBarDecoration: const NavBarDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });

    testWidgets(
        "#205 recreating the tabs config does not lose the navigation state of any tab",
        (tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(
              navBarConfig: config,
              navBarDecoration: const NavBarDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tapElevatedButton(tester);
      expectTab(0, level: 1);

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            tabs: tabs(),
            navBarBuilder: (config) => Style1BottomNavBar(
              navBarConfig: config,
              navBarDecoration: const NavBarDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expectTab(0, level: 1);
    });
  });
}
