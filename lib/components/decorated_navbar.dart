part of "../persistent_bottom_nav_bar_v2.dart";

class DecoratedNavBar extends StatelessWidget {
  const DecoratedNavBar({
    required this.child,
    super.key,
    this.decoration = const NavBarDecoration(),
    this.height,
  });

  final NavBarDecoration decoration;
  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          if ((decoration.color?.a ?? 1) < 1 && decoration.filter != null)
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: decoration.filter!,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          DecoratedBox(
            decoration: decoration,
            child: SafeArea(
              top: false,
              right: false,
              left: false,

              child: Container(
                padding: decoration.padding,
                height:
                    height != null ? height! - decoration.borderHeight() : null,
                child: child,
              ),
            ),
          ),
        ],
      );
}
