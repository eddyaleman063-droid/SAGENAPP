import 'package:flutter/material.dart';

class AppTransitions {
  AppTransitions._();

  static const _duration = Duration(milliseconds: 200);
  static const _curve = Curves.easeOut;

  static Route<T> _build<T>(
    Widget page,
    Widget Function(Animation<double>, Widget) builder, {
    Duration? duration,
  }) {
    final d = duration ?? _duration;
    return PageRouteBuilder<T>(
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) => builder(animation, child),
      transitionDuration: d,
      reverseTransitionDuration: d,
    );
  }

  static Route<T> fade<T>(Widget page, {Duration? duration}) => _build<T>(
    page,
    (a, c) => FadeTransition(opacity: a, child: c),
    duration: duration,
  );

  static Route<T> slide<T>(Widget page, {Duration? duration}) => _build<T>(
    page,
    (a, c) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: a, curve: _curve)),
      child: c,
    ),
    duration: duration,
  );

  static Route<T> modal<T>(Widget page, {Duration? duration}) => _build<T>(
    page,
    (a, c) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.4),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: a, curve: _curve)),
      child: FadeTransition(opacity: a, child: c),
    ),
    duration: duration,
  );

  static Route<T> lesson<T>(Widget page, {Duration? duration}) => _build<T>(
    page,
    (a, c) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.8, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: a, curve: _curve)),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 0.5,
          end: 1.0,
        ).animate(CurvedAnimation(parent: a, curve: _curve)),
        child: c,
      ),
    ),
    duration: duration,
  );

  static Route<T> reward<T>(Widget page, {Duration? duration}) => _build<T>(
    page,
    (a, c) => ScaleTransition(
      scale: Tween<double>(
        begin: 0.85,
        end: 1.0,
      ).animate(CurvedAnimation(parent: a, curve: _curve)),
      child: FadeTransition(opacity: a, child: c),
    ),
    duration: duration,
  );
}
