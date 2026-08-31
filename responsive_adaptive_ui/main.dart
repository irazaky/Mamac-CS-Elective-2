import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blueGrey),
      home: const DashboardScreen(),
    );
  }
}

// PLATFORM DETECTION
bool get isApple => !kIsWeb && (Platform.isIOS || Platform.isMacOS);

// RESPONSIVE BREAKPOINTS
enum DeviceType { mobile, tablet, desktop }

DeviceType deviceOf(double w) {
  if (w < 600) return DeviceType.mobile;
  if (w < 1024) return DeviceType.tablet;
  return DeviceType.desktop;
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        switch (deviceOf(c.maxWidth)) {
          case DeviceType.mobile:
            return const MobileLayout();
          case DeviceType.tablet:
            return const TabletLayout();
          case DeviceType.desktop:
            return const DesktopLayout();
        }
      },
    );
  }
}

// MOBILE: drawer nav, 2-column grid
class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key});
  @override
  Widget build(BuildContext context) {
    if (isApple) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Dashboard')),
        child: SafeArea(
          child: Column(
            children: [
              CupertinoButton(
                child: const Text('Menu'),
                onPressed: () => showCupertinoModalPopup(
                  context: context,
                  builder: (_) => CupertinoActionSheet(
                    actions: navItems
                        .map((i) => CupertinoActionSheetAction(
                              onPressed: () => Navigator.pop(context),
                              child: Text(i.label),
                            ))
                        .toList(),
                  ),
                ),
              ),
              const Expanded(child: DashboardBody(columns: 2, bigPanel: false)),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: const NavDrawer(),
      body: const DashboardBody(columns: 2, bigPanel: false),
    );
  }
}

// TABLET: same as mobile, 4-column grid
class TabletLayout extends StatelessWidget {
  const TabletLayout({super.key});
  @override
  Widget build(BuildContext context) {
    if (isApple) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Dashboard')),
        child: const SafeArea(child: DashboardBody(columns: 4, bigPanel: false)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: const NavDrawer(),
      body: const DashboardBody(columns: 4, bigPanel: false),
    );
  }
}

// DESKTOP: permanent sidebar, 4-column grid + big panel
class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});
  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        SizedBox(width: 220, child: NavSidebar()),
        Expanded(child: DashboardBody(columns: 4, bigPanel: true)),
      ],
    );
    if (isApple) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Dashboard')),
        child: SafeArea(child: content),
      );
    }
    return Scaffold(appBar: AppBar(title: const Text('Dashboard')), body: content);
  }
}

// SHARED: grid + rows + adaptive button
class DashboardBody extends StatelessWidget {
  final int columns;
  final bool bigPanel;
  const DashboardBody({super.key, required this.columns, required this.bigPanel});

  @override
  Widget build(BuildContext context) {
    final main = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: columns,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (_, __) => Box(color: Colors.grey.shade400),
          ),
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => Box(color: Colors.grey.shade200, height: 50),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AdaptiveButton(label: 'Click Me', onPressed: () {}),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
    if (!bigPanel) return main;
    return Row(
      children: [
        Expanded(flex: 3, child: main),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Box(color: Colors.grey.shade400, height: 400),
          ),
        ),
      ],
    );
  }
}

class Box extends StatelessWidget {
  final Color color;
  final double? height;
  const Box({super.key, required this.color, this.height});
  @override
  Widget build(BuildContext context) => Container(
        height: height,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      );
}

class NavItem {
  final IconData materialIcon, cupertinoIcon;
  final String label;
  const NavItem(this.materialIcon, this.cupertinoIcon, this.label);
}

const navItems = [
  NavItem(Icons.dashboard, CupertinoIcons.square_grid_2x2, 'Dashboard'),
  NavItem(Icons.settings, CupertinoIcons.gear, 'Settings'),
  NavItem(Icons.info_outline, CupertinoIcons.info, 'About'),
  NavItem(Icons.logout, CupertinoIcons.square_arrow_right, 'Logout'),
];

// mobile/tablet drawer (Material only)
class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});
  @override
  Widget build(BuildContext context) => Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.all(24), child: Icon(Icons.favorite, size: 40)),
              for (final i in navItems)
                ListTile(leading: Icon(i.materialIcon), title: Text(i.label), onTap: () => Navigator.pop(context)),
            ],
          ),
        ),
      );
}

// desktop sidebar
class NavSidebar extends StatelessWidget {
  const NavSidebar({super.key});
  @override
  Widget build(BuildContext context) => Container(
        color: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.all(24), child: Icon(Icons.favorite, size: 40)),
            for (final i in navItems)
              ListTile(leading: Icon(isApple ? i.cupertinoIcon : i.materialIcon), title: Text(i.label), onTap: () {}),
          ],
        ),
      );
}

// adaptive button: Cupertino on iOS, Material elsewhere
class AdaptiveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const AdaptiveButton({super.key, required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    if (isApple) return CupertinoButton.filled(onPressed: onPressed, child: Text(label));
    final button = ElevatedButton(onPressed: onPressed, child: Text(label));
    return kIsWeb ? Tooltip(message: label, child: button) : button;
  }
}
