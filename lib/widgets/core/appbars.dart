import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/core/responsive.dart';

class AppBarX extends StatelessWidget implements PreferredSizeWidget {
  const AppBarX({
    super.key,
    this.title,
    this.centerTitle,
    this.mobileBar,
    this.webBar,
    this.center,
    this.height = 45,
    this.trailing,
    this.leading,
    this.bgColor,
    this.textStyle,
    this.elevation,
  }) : assert(
          title != null || center != null,
          'You must provide either a title or a center widget',
        );

  final String? title;
  final Widget? mobileBar;
  final Widget? webBar;
  final double height;
  final bool? centerTitle;
  final Widget? trailing;
  final Widget? center;
  final Widget? leading;
  final Color? bgColor;
  final TextStyle? textStyle;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return context.isSmallScreen
        ? Container(
            padding: elevation != null
                ? const EdgeInsets.symmetric(horizontal: 0, vertical: 5)
                : const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
            child: Center(
              child: mobileBar ??
                  AppBar(
                      systemOverlayStyle: const SystemUiOverlayStyle(
                        statusBarColor: white, // <-- SEE HERE
                        statusBarIconBrightness: Brightness
                            .dark, //<-- For Android SEE HERE (dark icons)
                        statusBarBrightness: Brightness
                            .light, //<-- For iOS SEE HERE (dark icons)
                      ),
                      centerTitle: centerTitle ?? false,
                      leading: leading ??
                          BackBtnX(
                            padding: elevation != null
                                ? const EdgeInsets.only(left: 7,top: 5,bottom: 5)
                                : const EdgeInsets.all(2),
                          ),
                      backgroundColor: bgColor ?? Colors.white,
                      surfaceTintColor:  bgColor ?? Colors.white,
                      // forceMaterialTransparency: true,
                      title: center ??
                          Text(
                            title!,
                            style: textStyle ??
                                const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff002055)),
                          ),
                      actions: trailing != null ? <Widget>[trailing!] : [],
                      elevation: elevation ?? 0,
                      shadowColor: Colors.grey.withOpacity(0.3),
                      toolbarHeight: height),
            ),
          )
        : webBar ?? const SizedBox.shrink();
  }

  @override
  Size get preferredSize => Size.fromHeight(height + 12);
}

class AppBarWithSearchIconX extends StatefulWidget
    implements PreferredSizeWidget {
  const AppBarWithSearchIconX({
    super.key,
    this.title,
    this.centerTitle,
    this.mobileBar,
    this.webBar,
    this.center,
    this.height = 45,
    this.trailing,
    this.leading,
    this.bgColor,
    this.textStyle,
    this.elevation, required this.onSearchQueryChanged,
  }) : assert(
          title != null || center != null,
          'You must provide either a title or a center widget',
        );

  final String? title;
  final Widget? mobileBar;
  final Widget? webBar;
  final double height;
  final bool? centerTitle;
  final Widget? trailing;
  final Widget? center;
  final Widget? leading;
  final Color? bgColor;
  final TextStyle? textStyle;
  final double? elevation;
  final Function(String) onSearchQueryChanged;


  @override
  State<AppBarWithSearchIconX> createState() => _AppBarWithSearchIconXState();

  @override
  Size get preferredSize => Size.fromHeight(height + 12);
}

class _AppBarWithSearchIconXState extends State<AppBarWithSearchIconX>
    with SingleTickerProviderStateMixin {
  double? rippleStartX, rippleStartY;
  late final AnimationController _controller;
  Animation? _animation;
  bool isInSearchMode = false;

  @override
  initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _controller.addStatusListener(animationStatusListener);
  }

  animationStatusListener(AnimationStatus animationStatus) {
    if (animationStatus == AnimationStatus.completed) {
      setState(() {
        isInSearchMode = true;
      });
    }
  }

  void onSearchTapUp(TapUpDetails details) {
    setState(() {
      rippleStartX = details.globalPosition.dx;
      rippleStartY = details.globalPosition.dy;
    });
    _controller.forward();
  }

  cancelSearch() {
    setState(() {
      isInSearchMode = false;
    });
    widget.onSearchQueryChanged('');
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: white, // <-- SEE HERE
              statusBarIconBrightness:
                  Brightness.dark, //<-- For Android SEE HERE (dark icons)
              statusBarBrightness:
                  Brightness.light, //<-- For iOS SEE HERE (dark icons)
            ),
            centerTitle: widget.centerTitle ?? false,
            leading: widget.leading ??
                BackBtnX(
                  padding: widget.elevation != null
                      ? const EdgeInsets.all(3)
                      : const EdgeInsets.all(2),
                ),
            backgroundColor: widget.bgColor ?? white,
            title: widget.center ??
                Text(
                  widget.title!,
                  style: widget.textStyle ??
                      const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff002055)),
                ),
            actions: [
              GestureDetector(
                onTapUp: onSearchTapUp,
                child: Container(
                  padding: ResponsiveDesign.only(context,right: 20),
                  child: const Icon(
                    CupertinoIcons.search,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
              ),
              if (widget.trailing != null) ...[
                ...[widget.trailing!]
              ]
            ],
            elevation: widget.elevation ?? 0,
            shadowColor: Colors.grey.withOpacity(0.3),
            toolbarHeight: widget.height),
        AnimatedBuilder(
          animation: _animation!,
          builder: (context, child) {
            return CustomPaint(
              painter: MyPainter(
                  containerHeight: widget.preferredSize.height,
                  center: Offset(rippleStartX ?? 0, rippleStartY ?? 0),
                  radius:
                      _animation!.value * ResponsiveDesign.screenWidth(context),
                  context: context,
                  screenWidth: MediaQuery.of(context).size.width,
                  statusBarHeight: MediaQuery.of(context).padding.top),
            );
          },
        ),
        isInSearchMode
            ? (SearchBar(
                onCancelSearch: cancelSearch,
                onSearchQueryChanged: widget.onSearchQueryChanged,
              ))
            : (Container())
      ],
    );
  }
}

class MyPainter extends CustomPainter {
  final Offset center;
  final double radius, containerHeight;
  final BuildContext context;

  Color color;
  double statusBarHeight, screenWidth;

  MyPainter({
    required this.context,
    required this.containerHeight,
    required this.center,
    required this.radius,
    required this.statusBarHeight,
    required this.screenWidth,
    this.color = whitesmoke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint circlePainter = Paint();

    circlePainter.color = color;
    canvas.clipRect(
        Rect.fromLTWH(0, 0, screenWidth, containerHeight + statusBarHeight));
    canvas.drawCircle(center, radius, circlePainter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class SearchBar extends StatefulWidget implements PreferredSizeWidget {
  const SearchBar({
    Key? key,
    required this.onCancelSearch,
    required this.onSearchQueryChanged,
  }) : super(key: key);

  final VoidCallback onCancelSearch;
  final Function(String) onSearchQueryChanged;

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar>
    with SingleTickerProviderStateMixin {
  String searchQuery = '';
  final TextEditingController _searchFieldController = TextEditingController();

  clearSearchQuery() {
    _searchFieldController.clear();
    widget.onSearchQueryChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: widget.onCancelSearch,
              ),
              Expanded(
                child: TextField(
                  controller: _searchFieldController,
                  cursorColor: Colors.black,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    hintText: "Search...",
                    hintStyle: const TextStyle(color: Colors.black),
                    suffixIcon: InkWell(
                      onTap: clearSearchQuery,
                      child: const Icon(Icons.close, color: Colors.black),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    border: OutlineInputBorder(

                        borderRadius: BorderRadius.circular(50)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  onChanged: widget.onSearchQueryChanged,
                ),
              ),
              SizedBox(
                width: ResponsiveDesign.width(15, context),
              )
            ],
          ),
        ],
      ),
    );
  }
}
