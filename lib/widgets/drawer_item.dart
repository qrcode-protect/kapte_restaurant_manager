import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libertyrestaurant/routing/route_state.dart';

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    Key? key,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.drawerState,
    required this.drawerWidth,
    required this.value,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final Function(String value) onTap;
  final bool drawerState;
  final double drawerWidth;
  final String value;

  @override
  Widget build(BuildContext context) {
    var currentRoute = RouteStateScope.of(context).route;

    return InkWell(
      child: Container(
        width: drawerWidth,
        height: 70.0,
        decoration: const BoxDecoration(
          shape: BoxShape.rectangle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer(builder: (context, ref, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Icon(
                      icon,
                      color: currentRoute.pathTemplate == value
                          ? Theme.of(context).secondaryHeaderColor
                          : null,
                    ),
                  ),
                  if (drawerState)
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: currentRoute.pathTemplate == value
                              ? Theme.of(context).secondaryHeaderColor
                              : null,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
      onTap: () => onTap(value),
    );
  }
}
