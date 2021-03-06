import 'package:flutter/material.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class AppIconHeader extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final double size;

  AppIconHeader({
    this.padding = const EdgeInsets.symmetric(vertical: 80.0),
    this.size = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Material(
        elevation: 1.0,
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: Ink.image(
          image: AssetImage('assets/images/icon-small.png'),
          fit: BoxFit.cover,
          width: size,
          height: size,
          child: InkWell(
            onTap: () => FluroRouter.router.navigateTo(context, HomeRoute),
          ),
        ),
      ),
    );
  }
}
