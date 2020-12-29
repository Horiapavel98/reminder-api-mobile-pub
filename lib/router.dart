import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Route createRoute(StatelessWidget screen) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionDuration: const Duration(milliseconds: 750),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(3.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      }
  );
}