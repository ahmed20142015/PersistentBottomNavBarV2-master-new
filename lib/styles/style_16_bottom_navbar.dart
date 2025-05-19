part of "../persistent_bottom_nav_bar_v2.dart";

class Style16BottomNavBar extends StatelessWidget {
  Style16BottomNavBar({
    required this.navBarConfig,
    this.navBarDecoration = const NavBarDecoration(),
    this.height,
    this.middleItemSize = 50,
    super.key,
  }) : assert(
          navBarConfig.items.length.isOdd,
          "The number of items must be odd for this style",
        );

  final NavBarConfig navBarConfig;
  final NavBarDecoration navBarDecoration;
  final double? height;
  final double middleItemSize;

  Widget _buildItem(ItemConfig item, bool isSelected) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconTheme(
            data: IconThemeData(
              size: item.iconSize,
              color: isSelected
                  ? item.activeForegroundColor
                  : item.inactiveForegroundColor,
            ),
            child: isSelected ? item.icon : item.inactiveIcon,
          ),
          if (item.title != null)
            FittedBox(
              child: Text(
                item.title!,
                style: item.textStyle.apply(
                  color: isSelected
                      ? item.activeForegroundColor
                      : item.inactiveForegroundColor,
                ),
              ),
            ),
        ],
      );

  Widget _buildMiddleItem(ItemConfig item, bool isSelected) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 5, right: 5),
            height: middleItemSize,
            width: middleItemSize,
            decoration: BoxDecoration(
              color: item.activeForegroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconTheme(
              data: IconThemeData(
                size: item.iconSize,
                color: isSelected
                    ? item.activeForegroundColor
                    : item.inactiveForegroundColor,
              ),
              child: isSelected ? item.icon : item.inactiveIcon,
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final midIndex = (navBarConfig.items.length / 2).floor();
    return DecoratedNavBar(
      decoration: navBarDecoration,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navBarConfig.items.map((item) {
          final int index = navBarConfig.items.indexOf(item);
          return Expanded(
            child: InkWell(
              onTap: () {
                navBarConfig.onItemSelected(index);
              },
              child: index == midIndex
                  ? _buildMiddleItem(
                      item,
                      navBarConfig.selectedIndex == index,
                    )
                  : _buildItem(
                      item,
                      navBarConfig.selectedIndex == index,
                    ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
