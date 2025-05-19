part of "../persistent_bottom_nav_bar_v2.dart";

class Style9BottomNavBar extends StatelessWidget {
  const Style9BottomNavBar({
    required this.navBarConfig,
    super.key,
    this.navBarDecoration = const NavBarDecoration(padding: EdgeInsets.symmetric(horizontal: 5,vertical: 0)),
    this.itemAnimationProperties = const ItemAnimation(),
    this.height,
  });

  final NavBarConfig navBarConfig;
  final NavBarDecoration navBarDecoration;
  final double? height;

  /// This controls the animation properties of the items of the NavBar.
  final ItemAnimation itemAnimationProperties;

  Widget _buildItem(ItemConfig item, bool isSelected, int itemIndex) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: itemAnimationProperties.duration,
          curve: itemAnimationProperties.curve,
          transform: isSelected
              ? Matrix4.translationValues(0, -25, 0)
              : Matrix4.identity(),
          child: Container(
            width: isSelected ? 50 : 30,
            height: isSelected ? 50 : 30,
            decoration: isSelected
                ? BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF887C3C), Color(0xFFEED969)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            )
                : null,
            alignment: Alignment.center,
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
        ),

        // Title
        Visibility(
          visible: isSelected,
          replacement: SizedBox(height: 0,),
          child: AnimatedContainer(
            duration: itemAnimationProperties.duration,
            child: AnimatedSlide(
              duration: itemAnimationProperties.duration,
              offset: Offset(0, isSelected ? -1.2 : 0.5), // Adjusted offset
              child: Text(
                item.title ?? '',
                style: item.textStyle.apply(
                  color: Color(0xffE8C85A),
                ).copyWith(height: -0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => DecoratedNavBar(
    decoration: navBarDecoration,
    height: height,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: navBarConfig.items.map((item) {
          final int index = navBarConfig.items.indexOf(item);
          return Expanded(
            child: InkWell(
              onTap: () {
                navBarConfig.onItemSelected(index);
              },
              child: _buildItem(
                item,
                navBarConfig.selectedIndex == index,
                index,
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}
